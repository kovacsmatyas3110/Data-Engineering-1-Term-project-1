-- This script creates a new database with tables based on our csv files. After that it creates joins between the tables

-- Creating a new database:
DROP SCHEMA IF EXISTS ucl;
CREATE SCHEMA ucl;

USE ucl;
-- Creating the structure of the database:

-- Turn on the local infile for loading the csv
SET GLOBAL local_infile = 1;

-- attacking table:
DROP TABLE IF EXISTS attacking;
CREATE TABLE attacking (
	ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    assists INT,
    corner_taken INT,
    offsides INT,
    dribbles INT,
    match_played INT,
    PRIMARY KEY (ID)
);


-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/attacking.csv' 
INTO TABLE attacking 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, assists, corner_taken, offsides, dribbles, match_played);

-- attemts table:
DROP TABLE IF EXISTS attempts;
CREATE TABLE attempts (
    ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    total_attempts INT,
    on_target INT,
    off_target INT,
    blocked INT,
    match_played INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/attempts.csv' 
INTO TABLE attempts 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, total_attempts, on_target, off_target, blocked, match_played);

-- defendending table:
DROP TABLE IF EXISTS defending;
CREATE TABLE defending (
    ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    balls_recovered INT,
    tackles INT,
    t_won INT,
    t_lost INT,
    clearance_attempted INT,
    match_played INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/defending.csv' 
INTO TABLE defending 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, balls_recovered, tackles, t_won, t_lost, clearance_Attempted, match_played);

-- disciplinary table:
DROP TABLE IF EXISTS disciplinary;
CREATE TABLE disciplinary (
    ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    fouls_committed INT,
    fouls_suffered INT,
    red INT,
    yellow INT,
    minutes_played INT,
    match_played INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/disciplinary.csv' 
INTO TABLE disciplinary 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, fouls_committed, fouls_suffered, red, yellow, minutes_played, match_played);

-- distribution table:
DROP TABLE IF EXISTS distributon;
CREATE TABLE distributon (
    ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    pass_accuracy DECIMAL(5,2),
    pass_attempted INT,
    pass_completed INT,
    cross_accuracy DECIMAL(5,2),
    cross_attempted INT,
    cross_completed INT,
    freekicks_taken INT,
    match_played INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/distributon.csv' 
INTO TABLE distributon 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, pass_accuracy, pass_attempted, pass_completed, cross_accuracy, cross_attempted, cross_completed, freekicks_taken, match_played);

-- goalkeeping table:
DROP TABLE IF EXISTS goalkeeping;
CREATE TABLE goalkeeping (
    ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    saved INT,
    conceded INT,
    saved_penalties INT,
    cleansheets INT,
    punches_made INT,
    match_played INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/goalkeeping.csv' 
INTO TABLE goalkeeping 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, saved, conceded, saved_penalties, cleansheets, punches_made, match_played);

-- goals table:
DROP TABLE IF EXISTS goals;
CREATE TABLE goals (
    ID INT AUTO_INCREMENT,
    ranking INT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    goals INT,
    right_foot INT,
    left_foot INT,
    headers INT,
    other INT,
    inside_area INT,
    outside_area INT,
    penalties INT,
    match_played INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/goals.csv' 
INTO TABLE goals 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(ranking, player_name, club, position, goals, right_foot, left_foot, headers, other, inside_area, outside_area, penalties, match_played);

-- key_stats table:
DROP TABLE IF EXISTS key_stats;
CREATE TABLE key_stats (
	ID INT AUTO_INCREMENT,
    player_name VARCHAR(255),
    player_ID INT,
    club VARCHAR(255),
    position VARCHAR(50),
    minutes_played INT,
    match_played INT,
    goals INT,
    assists INT,
    distance_covered INT,
    PRIMARY KEY (ID)
);

-- load the data into the table:
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/database/key_stats.csv' 
INTO TABLE key_stats 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n' 
IGNORE 1 LINES 
(player_name, club, position, minutes_played, match_played, goals, assists, distance_covered);


-- Creating a table which contains all the players
DROP TABLE IF EXISTS players;
CREATE TABLE players (
	ID INT AUTO_INCREMENT,
    player_name VARCHAR(255),
    club VARCHAR(255),
    position VARCHAR(50),
    PRIMARY KEY (ID)
);

-- Fill up the table without duplicates
INSERT INTO players (player_name, club, position)
SELECT player_name, club, position FROM attacking
UNION
SELECT player_name, club, position FROM attempts
UNION
SELECT player_name, club, position FROM defending
UNION
SELECT player_name, club, position FROM disciplinary
UNION
SELECT player_name, club, position FROM distributon
UNION
SELECT player_name, club, position FROM goalkeeping
UNION
SELECT player_name, club, position FROM goals
UNION
SELECT player_name, club, position FROM key_stats;


-- Fill up the player_ID's and remove the player_names
SET SQL_SAFE_UPDATES = 0;

UPDATE attacking atck
JOIN players p ON atck.player_name = p.player_name AND atck.club = p.club AND atck.position = p.position
SET atck.player_ID = p.ID;
ALTER TABLE attacking DROP COLUMN player_name;

UPDATE attempts atps
JOIN players p ON atps.player_name = p.player_name AND atps.club = p.club AND atps.position = p.position
SET atps.player_ID = p.ID;
ALTER TABLE attempts DROP COLUMN player_name;

UPDATE defending def
JOIN players p ON def.player_name = p.player_name AND def.club = p.club AND def.position = p.position
SET def.player_ID = p.ID;
ALTER TABLE defending DROP COLUMN player_name;

UPDATE disciplinary disc
JOIN players p ON disc.player_name = p.player_name AND disc.club = p.club AND disc.position = p.position
SET disc.player_ID = p.ID;
ALTER TABLE disciplinary DROP COLUMN player_name;

UPDATE distributon dist
JOIN players p ON dist.player_name = p.player_name AND dist.club = p.club AND dist.position = p.position
SET dist.player_ID = p.ID;
ALTER TABLE distributon DROP COLUMN player_name;

UPDATE goalkeeping gkp
JOIN players p ON gkp.player_name = p.player_name AND gkp.club = p.club AND gkp.position = p.position
SET gkp.player_ID = p.ID;
ALTER TABLE goalkeeping DROP COLUMN player_name;

UPDATE goals g
JOIN players p ON g.player_name = p.player_name AND g.club = p.club AND g.position = p.position
SET g.player_ID = p.ID;
ALTER TABLE goals DROP COLUMN player_name;

UPDATE key_stats ks
JOIN players p ON ks.player_name = p.player_name AND ks.club = p.club AND ks.position = p.position
SET ks.player_ID = p.ID;
ALTER TABLE key_stats DROP COLUMN player_name;


-- Creating joins based on player_ID

ALTER TABLE attacking
ADD CONSTRAINT `fk_attaking`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE attempts
ADD CONSTRAINT `fk_attempts`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE defending
ADD CONSTRAINT `fk_defending`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE disciplinary
ADD CONSTRAINT `fk_disciplinary`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE distributon
ADD CONSTRAINT `fk_distributon`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE goalkeeping
ADD CONSTRAINT `fk_goalkeeping`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE goals
ADD CONSTRAINT `fk_goals`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE key_stats
ADD CONSTRAINT `fk_key_stats`
FOREIGN KEY (player_ID)
REFERENCES players(ID)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

