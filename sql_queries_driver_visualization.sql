-- Business Question: Who are the most dominant formula 1 drivers of all time?

-- There were different point values for the same position over time. E.g. position 1 gave the driver 10 points, now it is 25 points.
-- To answer the business question, it is necessary to unify the point system.
-- We will use the point system: Rank 1 = 10 Points, Rank 2 = 9 Points, 

-- Add a new column named "points_new" to the "results" table
ALTER TABLE results ADD COLUMN points_new INTEGER;


-- Update the "points_new" column based on the "position" column
UPDATE results
SET points_new = CASE
                     WHEN position <= 10 THEN 11 - position
                     ELSE 0
                 END;

                
-- CREATE VIEW drivers_number_of_titles AS
SELECT 
    driver_name,
    SUBSTR(driver_name, 1, INSTR(driver_name, ' ') - 1) AS forename,
    SUBSTR(driver_name, INSTR(driver_name, ' ') + 1) AS surname,
    championships 
FROM 
    web_number_of_titles;

                
-- Join results table with drivers table
-- Show all time leading drivers in points
-- CREATE VIEW drivers_most_points_all_time AS
SELECT forename, surname, forename || ' ' || surname AS driver_name, SUM(points_new) AS points_all_time
FROM results r
JOIN drivers d ON r.driverId = d.driverId
GROUP BY driver_name
ORDER BY points_all_time DESC;


-- Show all time leading drivers in won races
-- CREATE VIEW drivers_most_races_won_all_time AS
SELECT forename, surname, COUNT(resultId) AS wins_all_time
FROM results r
JOIN drivers d ON r.driverId = d.driverId
WHERE positionOrder = 1
GROUP BY forename, surname
ORDER BY wins_all_time DESC;


-- Shows the amount of points on average per race by driver (who has driven 40 races or more)
-- CREATE VIEW drivers_most_points_per_race AS
   SELECT 
    race_count.forename,
    race_count.surname,
    race_count.total_races,
    COALESCE(points_all_time, 0) AS points_all_time,
    CASE 
        WHEN total_races > 0 THEN ROUND(COALESCE(CAST(points_all_time AS FLOAT) / total_races, 0), 2)
        ELSE 0
    END AS average_points_per_race
FROM
    (SELECT 
        d.forename,
        d.surname,
        COUNT(r.resultID) AS total_races
    FROM 
        results r
    JOIN drivers d ON r.driverId = d.driverId
    GROUP BY 
        d.forename,
        d.surname
    HAVING 
        COUNT(r.resultID) >= 40) AS race_count
LEFT JOIN
    (SELECT 
        d.forename,
        d.surname,
        SUM(r.points_new) AS points_all_time
    FROM 
        results r
    JOIN drivers d ON r.driverId = d.driverId
    GROUP BY 
        d.forename,
        d.surname) AS points_count ON race_count.forename = points_count.forename AND race_count.surname = points_count.surname
ORDER BY 
    average_points_per_race DESC;

   
-- Shows winning percentage of all drivers (who has driven 20 races or more)
-- CREATE VIEW drivers_winning_percentage AS
SELECT 
    race_count.forename,
    race_count.surname,
    race_count.total_races,
    COALESCE(wins_all_time, 0) AS wins_all_time,
    ROUND(COALESCE((wins_all_time * 100.0) / total_races, 0), 2) AS winning_percentage
FROM
    (SELECT 
        d.forename,
        d.surname,
        COUNT(r.resultID) AS total_races
    FROM 
        results r
    JOIN drivers d ON r.driverId = d.driverId
    GROUP BY 
        d.forename,
        d.surname
    HAVING 
        COUNT(r.resultID) > 20) AS race_count
LEFT JOIN
    (SELECT 
        d.forename,
        d.surname,
        COUNT(r.resultId) AS wins_all_time
    FROM 
        results r
    JOIN drivers d ON r.driverId = d.driverId
    WHERE 
        r.positionOrder = 1
    GROUP BY 
        d.forename,
        d.surname) AS win_count ON race_count.forename = win_count.forename AND race_count.surname = win_count.surname
ORDER BY 
    winning_percentage DESC;


-- CREATE VIEW drivers_most_starts_all_time AS
SELECT 
    driver_name,
    forename,
    surname,
    SUM(total_races) AS total_races 
FROM 
    drivers_performance_each_year_all_drivers
GROUP BY
	driver_name
ORDER BY
	SUM(total_races) DESC;


-- CREATE VIEW drivers_performance_each_year_all_drivers AS
WITH RankedData AS (
    SELECT 
        forename,
        surname,
        forename || ' ' || surname AS driver_name,
        race_year,
        total_races,
        points_this_season,
        wins_this_season,
        winning_percentage,
        ROUND(average_points_per_race, 2) AS average_points_per_race,
        points_all_time,
        winning_percentage_all_time,
        average_points_per_race_all_time,
        championships,
        wins_all_time
    FROM (
        SELECT 
            d.forename,
            d.surname,
            strftime('%Y', ra.date) AS race_year,
            COUNT(r.resultID) AS total_races,
            SUM(r.points_new) AS points_this_season,
            COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) AS wins_this_season,
            CASE 
                WHEN COUNT(r.resultID) > 0 THEN ROUND(COUNT(CASE WHEN r.positionOrder = 1 THEN 1 END) * 100.0 / COUNT(r.resultID), 2)
                ELSE 0
            END AS winning_percentage,
            CASE 
                WHEN COUNT(r.resultID) > 0 THEN SUM(r.points_new) / CAST(COUNT(r.resultID) AS REAL)
                ELSE 0
            END AS average_points_per_race,
            COALESCE(dma.points_all_time, 0) AS points_all_time,
            COALESCE(dwp.winning_percentage, 0) AS winning_percentage_all_time,
            COALESCE(dmp.average_points_per_race, 0) AS average_points_per_race_all_time,
            COALESCE(dnt.championships, 0) AS championships,
            COALESCE(dmr.wins_all_time, 0) AS wins_all_time
        FROM 
            results r
        JOIN drivers d ON r.driverId = d.driverId
        JOIN races ra ON r.raceId = ra.raceId
        LEFT JOIN drivers_most_points_all_time dma ON d.forename = dma.forename AND d.surname = dma.surname
        LEFT JOIN drivers_winning_percentage dwp ON d.forename = dwp.forename AND d.surname = dwp.surname
        LEFT JOIN drivers_most_points_per_race dmp ON d.forename = dmp.forename AND d.surname = dmp.surname
        LEFT JOIN drivers_number_of_titles dnt ON d.forename = dnt.forename AND d.surname = dnt.surname
        LEFT JOIN drivers_most_races_won_all_time dmr ON d.forename = dmr.forename AND d.surname = dmr.surname
        GROUP BY 
            d.forename,
            d.surname,
            strftime('%Y', ra.date)
    ) AS subquery
)
SELECT 
    forename,
    surname,
    driver_name,
    race_year,
    total_races,
    points_this_season,
    wins_this_season,
    winning_percentage,
    average_points_per_race,
    points_all_time,
    winning_percentage_all_time,
    average_points_per_race_all_time,
    championships,
    wins_all_time
FROM 
    RankedData
ORDER BY 
    race_year DESC,
    points_this_season DESC;


-- CREATE VIEW drivers_performance_final AS
WITH RankedData AS (
    SELECT 
        forename,
        surname,
        forename || ' ' || surname AS driver_name,
        points_all_time,
        winning_percentage_all_time,
        average_points_per_race_all_time,
        championships,
        wins_all_time,
        races_all_time
    FROM (
        SELECT 
            d.forename,
            d.surname,
            COALESCE(dma.points_all_time, 0) AS points_all_time,
            COALESCE(dwp.winning_percentage, 0) AS winning_percentage_all_time,
            COALESCE(dmp.average_points_per_race, 0) AS average_points_per_race_all_time,
            COALESCE(dnt.championships, 0) AS championships,
            COALESCE(dmr.wins_all_time, 0) AS wins_all_time,
            COALESCE(dms.total_races, 0) AS races_all_time
        FROM 
            results r
        JOIN drivers d ON r.driverId = d.driverId
        JOIN races ra ON r.raceId = ra.raceId
        LEFT JOIN drivers_most_points_all_time dma ON d.forename = dma.forename AND d.surname = dma.surname
        LEFT JOIN drivers_winning_percentage dwp ON d.forename = dwp.forename AND d.surname = dwp.surname
        LEFT JOIN drivers_most_points_per_race dmp ON d.forename = dmp.forename AND d.surname = dmp.surname
        LEFT JOIN drivers_number_of_titles dnt ON d.forename = dnt.forename AND d.surname = dnt.surname
        LEFT JOIN drivers_most_races_won_all_time dmr ON d.forename = dmr.forename AND d.surname = dmr.surname
        LEFT JOIN drivers_most_starts_all_time dms ON d.forename = dms.forename AND d.surname = dms.surname
        GROUP BY 
            d.forename,
            d.surname,
            strftime('%Y', ra.date)
    ) AS subquery
)
SELECT 
    forename,
    surname,
    driver_name,
    points_all_time,
    winning_percentage_all_time,
    average_points_per_race_all_time,
    championships,
    wins_all_time,
    races_all_time
FROM 
    RankedData
GROUP BY
	forename,
	surname,
	driver_name

	
-- Show the Top 20 drivers for visualization
-- CREATE VIEW drivers_performance_each_year_top_20 AS
SELECT *
FROM drivers_performance_each_year_all_drivers  
WHERE average_points_per_race_all_time >= 4.20
ORDER BY race_year DESC, average_points_per_race DESC;


-- CREATE VIEW drivers_performance_each_year_top_20_v2 AS
SELECT *
FROM drivers_performance_each_year_all_drivers  
WHERE average_points_per_race >= 5
ORDER BY race_year DESC, average_points_per_race DESC;


-- Join results table with constructors table
-- Show all time leading constructors in points
-- CREATE VIEW constructors_most_points_all_time AS
SELECT name, SUM(points_new) AS points_all_time
FROM results r
JOIN constructors c ON r.constructorId = c.constructorId
GROUP BY name
ORDER BY points_all_time DESC;


-- Show all time leading constructors in won races
-- CREATE VIEW constructors_most_wins_all_time AS
SELECT name, COUNT(resultId) AS wins_all_time
FROM results r
JOIN constructors c ON r.constructorId = c.constructorId
WHERE positionOrder = 1
GROUP BY name
ORDER BY wins_all_time DESC;


-- Shows winning percentage of all constructors (who have started 40 drivers or more)
-- CREATE VIEW constructors_winning_percentage AS
SELECT 
    constructor_count.name,
    constructor_count.total_starts,
    COALESCE(wins_all_time, 0) AS wins_all_time,
    ROUND(COALESCE((wins_all_time * 100.0) / total_starts, 0), 2) AS win_percentage
FROM
    (SELECT 
        c.name,
        COUNT(r.resultID) AS total_starts
    FROM 
        results r
    JOIN constructors c ON r.constructorId = c.constructorId
    GROUP BY 
        c.name
    HAVING 
        COUNT(r.resultID) >= 40) AS constructor_count
LEFT JOIN
    (SELECT 
        c.name,
        COUNT(r.resultId) AS wins_all_time
    FROM 
        results r
    JOIN constructors c ON r.constructorId = c.constructorId
    WHERE 
        r.positionOrder = 1
    GROUP BY 
        c.name) AS wins_count ON constructor_count.name = wins_count.name
ORDER BY 
    win_percentage DESC;
   
   
-- Shows the amount of points on average per start of all constructors (who have started 80 drivers or more)
-- CREATE VIEW constructors_most_points_per_start AS
SELECT 
    constructor_count.name,
    constructor_count.total_starts,
    COALESCE(points_all_time, 0) AS points_all_time,
    CASE 
        WHEN total_starts > 0 THEN ROUND(COALESCE(CAST(points_all_time AS FLOAT) / total_starts, 0), 2)
        ELSE 0
    END AS average_points_per_race
FROM
    (SELECT 
        c.name,
        COUNT(r.resultID) AS total_starts
    FROM 
        results r
    JOIN constructors c ON r.constructorId = c.constructorId
    GROUP BY 
        c.name
    HAVING 
        COUNT(r.resultID) >= 80) AS constructor_count
LEFT JOIN
    (SELECT 
        c.name,
        SUM(r.points_new) AS points_all_time
    FROM 
        results r
    JOIN constructors c ON r.constructorId = c.constructorId
    GROUP BY 
        c.name) AS points_count ON constructor_count.name = points_count.name
ORDER BY 
    average_points_per_race DESC;