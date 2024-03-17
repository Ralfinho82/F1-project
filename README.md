# f1-project
Private Formula 1 project using Python, SQL and Power BI to create a visualization to answer the question "Who was the most dominant driver in modern Formula 1".

### Project Overview

#### 1. Get csv-files trough Kaggle API - Technologies: Python & VSCode
To get the raw data for this project we are using the kaggle dataset found here: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020
Important: The data includes every race, driver from the beginning of F1 until the end of the 2023 season. All data of the 2023 season is inculded.
We are getting the data trough my personal kaggle account and the kaggle public API. We are using the Python library Opendatasets by doing so.
Check the get_data_trough_kaggle_api.py file for the code. 

#### 2. Create "f1 database" in SQLite - Technologies: SQLite & DBeaver
We are creating a SQLite database named "f1" with DBeaver Community edition. 
To view the ER model of the database please check: ergast_db.png as well as f1db_user_guide.txt 

#### 3. Create tables in "f1 database" on basis of ER model - Technologies: SQLite & DBeaver
According to the ER model the respective tables are created in the database.
Check the create_tables.sql file for the code. 

#### 4. Import data from csv files into "f1 database" tables - Technologies: SQLite & DBeaver
The data from the csv-files which are downlaoded in step 1 are now being imported via DBeaver into the created tables of the "f1 database".
This step is done by using the DBeaver UI.

#### 5. Transform data and create views for Power BI dashboards in order to answer the buisness questions - Technologies: SQLite & DBeaver
Business Question: Who are the most dominant Formula 1 drivers of in modern Formula 1 (beginning in 1980)?
A good KPI to measure the performance of a driver is his point average trough the years he started in F1.
Therefore calculationg the point average for each driver for each year is the first task.
However the F1 point system has changed over the years. Please see: https://en.wikipedia.org/wiki/List_of_Formula_One_World_Championship_points_scoring_systems#Points_scoring_systems

E.g. position 1 gave the driver 10 points, now it is 25 points. And from 1991 - 2002 only the first six drivers got points. Now the first ten drivers get points.
We are therefore facing the challenge of creating a unified scoring system.

The solution is to create the following system and apply it to every race result in every year:
Rank 1 = 10 Points 
Rank 2 = 9 Points
Rank 3 = 8 Points
Rank 4 = 7 Points
Rank 5 = 6 Points
Rank 6 = 5 Points
Rank 7 = 4 Points
Rank 8 = 3 Points
Rank 9 = 2 Points
Rank 10 = 1 Point

This allows for the average points per year KPI to be calculated and to determine the most dominant driver of modern Formula 1.
Please check the main code file of this project: sql_queries_driver_visualization.sql

#### 6. Search web and add new third party data into database (championships and driver pictures) - Technologies: Excel
After working with the dataset and having a good understanding of the data it contains, we realize there is no data about the number of won championships.
However we want to include this information in our final "F1 dashboard" as well as some pictures of the most dominant F1 drivers to make the dashboard more appealing.
Therefore we include the information of the number of championships won from the following website: https://en.wikipedia.org/wiki/List_of_Formula_One_World_Drivers%27_Champions#By_season

As repeat steps 3 and 4 in order to get the data into the "F1 database".

#### 7. Create "f1 dashboard" with Power BI - Technologies: Power BI
In the final step we use Power BI to create the "f1" dashboard in order to answer the business questions and present results.
Check the f1_dashboard.pbix file for the final result of the project.
