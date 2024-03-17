CREATE TABLE races (
    raceId INTEGER PRIMARY KEY AUTOINCREMENT,
    year INTEGER NOT NULL DEFAULT 0,
    round INTEGER NOT NULL DEFAULT 0,
    circuitId INTEGER NOT NULL DEFAULT 0,
    name TEXT NOT NULL,
    date DATE NOT NULL DEFAULT '0000-00-00',
    time TIME,
    url TEXT UNIQUE,
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    quali_date DATE,
    quali_time TIME,
    sprint_date DATE,
    sprint_time TIME
);

CREATE TABLE drivers (
    driverId INTEGER PRIMARY KEY AUTOINCREMENT,
    driverRef VARCHAR(255) NOT NULL,
    number INTEGER,
    code VARCHAR(3),
    forename VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    dob DATE,
    nationality VARCHAR(255),
    url VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE constructors (
    constructorId INTEGER PRIMARY KEY AUTOINCREMENT,
    constructorRef VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL UNIQUE,
    nationality VARCHAR(255),
    url VARCHAR(255) NOT NULL,
    UNIQUE (constructorRef)
);

CREATE TABLE circuits (
    circuitId INTEGER PRIMARY KEY AUTOINCREMENT,
    circuitRef VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    country VARCHAR(255),
    lat FLOAT,
    lng FLOAT,
    alt INT,
    url VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE lap_times (
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    lap INTEGER NOT NULL,
    position INTEGER,
    time VARCHAR(255),
    milliseconds INTEGER,
    PRIMARY KEY (raceId, driverId, lap),
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

CREATE TABLE pit_stops (
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    stop INTEGER NOT NULL,
    lap INTEGER NOT NULL,
    time TIME NOT NULL,
    duration VARCHAR(255),
    milliseconds INTEGER,
    PRIMARY KEY (raceId, driverId, stop),
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

CREATE TABLE qualifying (
    qualifyId INTEGER PRIMARY KEY AUTOINCREMENT,
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    constructorId INTEGER NOT NULL,
    number INTEGER NOT NULL,
    position INTEGER,
    q1 VARCHAR(255),
    q2 VARCHAR(255),
    q3 VARCHAR(255),
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId)
);

CREATE TABLE constructor_results (
    constructorResultsId INTEGER PRIMARY KEY AUTOINCREMENT,
    raceId INTEGER NOT NULL,
    constructorId INTEGER NOT NULL,
    points FLOAT,
    status VARCHAR(255),
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId)
);

CREATE TABLE constructor_standings (
    constructorStandingsId INTEGER PRIMARY KEY AUTOINCREMENT,
    raceId INTEGER NOT NULL,
    constructorId INTEGER NOT NULL,
    points FLOAT NOT NULL DEFAULT 0,
    position INTEGER,
    positionText VARCHAR(255),
    wins INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId)
);

CREATE TABLE driver_standings (
    driverStandingsId INTEGER PRIMARY KEY AUTOINCREMENT,
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    points FLOAT NOT NULL DEFAULT 0,
    position INTEGER,
    positionText VARCHAR(255),
    wins INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);
CREATE TABLE lap_times (
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    lap INTEGER NOT NULL,
    position INTEGER,
    time VARCHAR(255),
    milliseconds INTEGER,
    PRIMARY KEY (raceId, driverId, lap),
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

CREATE TABLE sprint_results (
    sprintResultId INTEGER PRIMARY KEY AUTOINCREMENT,
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    constructorId INTEGER NOT NULL,
    number INTEGER,
    grid INTEGER NOT NULL DEFAULT 0,
    position INTEGER,
    positionText VARCHAR(255) NOT NULL,
    positionOrder INTEGER NOT NULL DEFAULT 0,
    points FLOAT NOT NULL DEFAULT 0,
    laps INTEGER NOT NULL DEFAULT 0,
    time VARCHAR(255),
    milliseconds INTEGER,
    fastestLap INTEGER,
    fastestLapTime VARCHAR(255),
    statusId INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId),
    FOREIGN KEY (statusId) REFERENCES status(statusId)
);

CREATE TABLE seasons (
    year INTEGER PRIMARY KEY,
    url VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE status (
    statusId INTEGER PRIMARY KEY AUTOINCREMENT,
    status VARCHAR(255) NOT NULL
);

CREATE TABLE results (
    resultId INTEGER PRIMARY KEY AUTOINCREMENT,
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    constructorId INTEGER NOT NULL,
    number INTEGER,
    grid INTEGER NOT NULL DEFAULT 0,
    position INTEGER,
    positionText VARCHAR(255) NOT NULL,
    positionOrder INTEGER NOT NULL DEFAULT 0,
    points FLOAT NOT NULL DEFAULT 0,
    laps INTEGER NOT NULL DEFAULT 0,
    time VARCHAR(255),
    milliseconds INTEGER,
    fastestLap INTEGER,
    rank INTEGER DEFAULT 0,
    fastestLapTime VARCHAR(255),
    fastestLapSpeed VARCHAR(255),
    statusId INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (raceId) REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId),
    FOREIGN KEY (statusId) REFERENCES status(statusId)
);

-- Adding new data source
CREATE TABLE web_number_of_titles (
    driver_name VARCHAR(255) NOT NULL,
    championships INTEGER
);

CREATE TABLE web_driver_pictures  (
    driver_name VARCHAR(255) NOT NULL,
    link_private VARCHAR(255),
    link_public VARCHAR(255)
);