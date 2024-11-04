-- This SQL scrit creates a Data warehouse and then from the warehouse it creates 3 data marts for analysis

-- chouse the database
USE ucl;

-- Turn on event scheduler
SET GLOBAL event_scheduler = ON;

-- creating the data warehouse with a stored procedure
-- The last two column of the data warehouse is the sum of the rankings and the count of the tables where the player was included.
DROP PROCEDURE IF EXISTS CreatePlayerStatisticsStore;

DELIMITER //

CREATE PROCEDURE CreatePlayerStatisticsStore()
BEGIN

	DROP TABLE IF EXISTS player_statistics;
    
    CREATE TABLE player_statistics AS
    SELECT DISTINCT
		players.ID AS player_ID,
        players.player_name,
        players.club,
        players.position,
        attacking.assists,
        attacking.corner_taken,
        attacking.offsides,
        attacking.dribbles,
        attacking.match_played,
        disciplinary.minutes_played,
        attempts.total_attempts,
        attempts.on_target,
        attempts.off_target,
        attempts.blocked,
        defending.balls_recovered,
        defending.tackles,
        defending.t_won AS tackles_won,
        defending.t_lost AS tackles_lost,
        defending.clearance_attempted,
        disciplinary.fouls_committed,
        disciplinary.fouls_suffered,
        disciplinary.red AS red_card,
        disciplinary.yellow AS yellow_card,
        distributon.pass_accuracy,
        distributon.pass_attempted,
        distributon.pass_completed,
        distributon.freekicks_taken,
        goals.goals,
        goals.penalties,
        goals.right_foot AS right_foot_goals,
        goals.left_foot AS left_foot_goals,
        goals.headers AS header_goals,
        goalkeeping.saved AS saved_balls,
        goalkeeping.conceded AS conceded_goals,
        goalkeeping.saved_penalties,
        goalkeeping.cleansheets,
        goalkeeping.punches_made,
        key_stats.distance_covered,
		ranking_data.total_ranking,
		ranking_data.number_of_rankings
	FROM players
    LEFT JOIN attacking ON players.ID = attacking.player_ID
    LEFT JOIN attempts ON players.ID = attempts.player_ID
    LEFT JOIN defending ON players.ID = defending.player_ID
    LEFT JOIN disciplinary ON players.ID = disciplinary.player_ID
    LEFT JOIN distributon ON players.ID = distributon.player_ID
    LEFT JOIN goalkeeping ON players.ID = goalkeeping.player_ID
    LEFT JOIN goals ON players.ID = goals.player_ID
    LEFT JOIN key_stats ON players.ID = key_stats.player_ID
    LEFT JOIN (
		SELECT 
			player_ID,
			SUM(ranking) AS total_ranking,
			COUNT(ranking) AS number_of_rankings
		FROM (
			SELECT player_ID, ranking FROM attacking
            UNION ALL
			SELECT player_ID, ranking FROM attempts
			UNION ALL
			SELECT player_ID, ranking FROM defending
			UNION ALL
			SELECT player_ID, ranking FROM disciplinary
            UNION ALL
			SELECT player_ID, ranking FROM distributon
            UNION ALL
			SELECT player_ID, ranking FROM goalkeeping
            UNION ALL
			SELECT player_ID, ranking FROM goals
		) AS rankings
		GROUP BY player_ID
	) AS ranking_data ON players.ID = ranking_data.player_ID
    ORDER BY player_ID;
    
END //
DELIMITER ;

CALL CreatePlayerStatisticsStore();

-- 1. data mart: Analysing the difference between the positions.

-- Create a view which aswers the required question
DROP VIEW IF EXISTS position_stats_view;

CREATE VIEW `position_stats_view` AS
SELECT
	player_ID,
        position,
        total_attempts,
        balls_recovered,
        fouls_committed,
        red_Card,
        yellow_card,
        distance_covered,
        total_ranking,
        number_of_rankings,
        IF(number_of_rankings > 0, total_ranking / number_of_rankings, NULL) AS average_ranking
	FROM
		player_statistics
	ORDER BY
		player_ID;

-- Create a stored procedure which makes a table as the view
DROP PROCEDURE IF EXISTS CreatePositionDataStore;

DELIMITER //

CREATE PROCEDURE CreatePositionDataStore()
BEGIN
	
    DROP TABLE IF EXISTS position_stats;
    
    CREATE TABLE position_stats AS
    SELECT
		player_ID,
        position,
        total_attempts,
        balls_recovered,
        fouls_committed,
        red_Card,
        yellow_card,
        distance_covered,
        total_ranking,
        number_of_rankings,
        IF(number_of_rankings > 0, total_ranking / number_of_rankings, NULL) AS average_ranking
	FROM
		player_statistics
	ORDER BY
		player_ID;
        
	DELETE FROM position_stats
	WHERE average_ranking IS NULL;
        
END //
DELIMITER ;

CALL CreatePositionDataStore();

-- Creat an event to update our data everyday
DROP EVENT IF EXISTS CreatePositionDataStoreEvent;

DELIMITER $$

CREATE EVENT CreatePositionDataStoreEvent
ON SCHEDULE EVERY 1 day
STARTS CURRENT_TIMESTAMP
ENDS '2025-06-30 23:59:59'
DO
	BEGIN
		INSERT INTO messages SELECT CONCAT('event:',NOW());
    		CALL CreatePositionDataStore();
	END$$
DELIMITER ;


-- 2. data mart: Analysing the difference between the teams
DROP VIEW IF EXISTS team_stats_view;

-- Create a view which asnwers the required question
DROP VIEW IF EXISTS team_stats_view;

CREATE VIEW `team_stats_view` AS
SELECT
	club,
		COUNT(player_ID) AS number_of_players,
		SUM(goals) AS goals,
		SUM(assists) AS assists,
		SUM(penalties) AS penalty_goals,
		SUM(corner_taken) AS corners_taken,
		SUM(fouls_committed) AS fouls_committed,
		SUM(cleansheets) AS cleansheets,
		SUM(distance_covered) AS distance_covered
	FROM
		player_statistics
	GROUP BY
		club
	ORDER BY
		club;

-- Create a stored procedure which makes a table as the view
DROP PROCEDURE IF EXISTS CreateTeamDataStore;

DELIMITER //

CREATE PROCEDURE CreateTeamDataStore()
BEGIN
	
    DROP TABLE IF EXISTS team_stats;
    
    CREATE TABLE team_stats AS
    SELECT
		club,
		COUNT(player_ID) AS number_of_players,
		SUM(goals) AS goals,
		SUM(assists) AS assists,
		SUM(penalties) AS penalty_goals,
		SUM(corner_taken) AS corners_taken,
		SUM(fouls_committed) AS fouls_committed,
		SUM(cleansheets) AS cleansheets,
		SUM(distance_covered) AS distance_covered
	FROM
		player_statistics
	GROUP BY
		club
	ORDER BY
		club;
        
END //
DELIMITER ;

CALL CreateTeamDataStore();  

-- Creat an event to update our data everyday
DROP EVENT IF EXISTS CreateTeamDataStoreEvent;

DELIMITER $$

CREATE EVENT CreateTeamDataStoreEvent
ON SCHEDULE EVERY 1 day
STARTS CURRENT_TIMESTAMP
ENDS '2025-06-30 23:59:59'
DO
	BEGIN
		INSERT INTO messages SELECT CONCAT('event:',NOW());
    		CALL CreateTeamDataStore();
	END$$
DELIMITER ;      
       
-- 3. data mart: Most effective attacking player        
DROP VIEW IF EXISTS most_eff_att_player_view;

CREATE VIEW `most_eff_att_player_view` AS
SELECT
	player_name,
IFNULL(FLOOR(minutes_played / NULLIF(goals, 0)), 9999999) AS minutes_per_goal,
    IFNULL(FLOOR(minutes_played / NULLIF(assists, 0)), 9999999) AS minutes_per_assist,
    IFNULL(FLOOR(minutes_played / NULLIF(goals + assists, 0)), 9999999) AS minutes_per_goal_and_assist
FROM player_statistics
WHERE
    IFNULL(FLOOR(minutes_played / NULLIF(goals, 0)), 9999999) != 9999999
    OR IFNULL(FLOOR(minutes_played / NULLIF(assists, 0)), 9999999) != 9999999
    OR IFNULL(FLOOR(minutes_played / NULLIF(goals + assists, 0)), 9999999) != 9999999
ORDER BY
	minutes_per_goal;
    