CREATE DATABASE soccer_league;
GO

USE soccer_league;
GO

CREATE TABLE tag (
                tag_id BIGINT NOT NULL,
                name VARCHAR(50) NOT NULL,
                CONSTRAINT tag_pk PRIMARY KEY (tag_id)
)

CREATE TABLE event (
                event_id BIGINT NOT NULL,
                name VARCHAR(50) NOT NULL,
                CONSTRAINT event_pk PRIMARY KEY (event_id)
)

CREATE TABLE location_area (
                location_area_id BIGINT NOT NULL,
                alpha_3_code VARCHAR(3) NOT NULL,
                alpha_2_code VARCHAR(2) NOT NULL,
                name VARCHAR(50) NOT NULL,
                CONSTRAINT location_area_pk PRIMARY KEY (location_area_id)
)

CREATE TABLE role (
                role_id VARCHAR(2) NOT NULL,
                code3 VARCHAR(3) NOT NULL,
                name VARCHAR(50) NOT NULL,
                CONSTRAINT role_pk PRIMARY KEY (role_id)
)

CREATE TABLE player (
                player_id BIGINT NOT NULL,
                foot VARCHAR(6) NOT NULL,
                short_name VARCHAR(50) NOT NULL,
                weight SMALLINT NOT NULL,
                first_name VARCHAR(50) NOT NULL,
                middle_name VARCHAR(50) DEFAULT '' NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                height SMALLINT NOT NULL,
                birth_date DATETIME NOT NULL,
                role_id VARCHAR(2) NOT NULL,
                passport_area_id BIGINT,
                birth_area_id BIGINT,
                CONSTRAINT player_pk PRIMARY KEY (player_id)
)

CREATE TABLE team (
                team_id BIGINT NOT NULL,
                type VARCHAR(10) NOT NULL,
                city VARCHAR(150) NOT NULL,
                name VARCHAR(100) NOT NULL,
                CONSTRAINT team_pk PRIMARY KEY (team_id)
)

CREATE TABLE team_player (
                team_player_id BIGINT IDENTITY NOT NULL,
                player_id BIGINT NOT NULL,
                team_id BIGINT NOT NULL,
                dorsal SMALLINT NOT NULL,
                CONSTRAINT team_player_pk PRIMARY KEY (team_player_id)
)

CREATE TABLE competition (
                competition_id BIGINT IDENTITY NOT NULL,
                name VARCHAR(100) NOT NULL,
                CONSTRAINT competition_pk PRIMARY KEY (competition_id)
)

CREATE TABLE season (
                season_id BIGINT IDENTITY NOT NULL,
                name VARCHAR(9) NOT NULL,
                CONSTRAINT season_pk PRIMARY KEY (season_id)
)

CREATE TABLE season_competition (
                season_competition_id BIGINT IDENTITY NOT NULL,
                season_id BIGINT NOT NULL,
                competition_id BIGINT NOT NULL,
                description VARCHAR(100) NOT NULL,
                CONSTRAINT season_competition_pk PRIMARY KEY (season_competition_id)
)

CREATE TABLE match (
                match_id BIGINT NOT NULL,
                season_competition_id BIGINT NOT NULL,
                home_team_id BIGINT NOT NULL,
                away_team_id BIGINT NOT NULL,
                status VARCHAR(50) NOT NULL,
                winner_team_id BIGINT,
                venue VARCHAR(100) NOT NULL,
                home_score SMALLINT DEFAULT 0 NOT NULL,
                away_score SMALLINT DEFAULT 0 NOT NULL,
                CONSTRAINT match_pk PRIMARY KEY (match_id)
)

CREATE TABLE match_event (
                match_event_id BIGINT NOT NULL,
                event_id BIGINT NOT NULL,
                match_id BIGINT NOT NULL,
                player_id BIGINT NOT NULL,
                team_id BIGINT NOT NULL,
                match_period VARCHAR(2) NOT NULL,
                event_sec DECIMAL(10,6) NOT NULL,
                CONSTRAINT match_event_pk PRIMARY KEY (match_event_id)
)

CREATE TABLE tag_match_event (
                tag_match_event_id BIGINT NOT NULL,
                tag_id BIGINT NOT NULL,
                match_event_id BIGINT NOT NULL,
                CONSTRAINT tag_match_event_pk PRIMARY KEY (tag_match_event_id)
)

CREATE TABLE player_match (
                player_match_id BIGINT IDENTITY NOT NULL,
                match_id BIGINT NOT NULL,
                player_id BIGINT NOT NULL,
                team_id BIGINT NOT NULL,
                is_starter BIT DEFAULT 0 NOT NULL,
                CONSTRAINT player_match_pk PRIMARY KEY (player_match_id)
)

ALTER TABLE tag_match_event ADD CONSTRAINT tag_tag_match_event_fk
FOREIGN KEY (tag_id)
REFERENCES tag (tag_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match_event ADD CONSTRAINT event_match_event_fk
FOREIGN KEY (event_id)
REFERENCES event (event_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE player ADD CONSTRAINT location_area_player_fk
FOREIGN KEY (passport_area_id)
REFERENCES location_area (location_area_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE player ADD CONSTRAINT location_area_player_fk1
FOREIGN KEY (birth_area_id)
REFERENCES location_area (location_area_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE player ADD CONSTRAINT role_player_fk
FOREIGN KEY (role_id)
REFERENCES role (role_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE player_match ADD CONSTRAINT player_player_match_fk
FOREIGN KEY (player_id)
REFERENCES player (player_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE team_player ADD CONSTRAINT player_team_player_fk
FOREIGN KEY (player_id)
REFERENCES player (player_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match_event ADD CONSTRAINT player_match_event_fk
FOREIGN KEY (player_id)
REFERENCES player (player_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match ADD CONSTRAINT team_match_fk
FOREIGN KEY (home_team_id)
REFERENCES team (team_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match ADD CONSTRAINT team_match_fk1
FOREIGN KEY (away_team_id)
REFERENCES team (team_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE player_match ADD CONSTRAINT team_player_match_fk
FOREIGN KEY (team_id)
REFERENCES team (team_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match ADD CONSTRAINT team_match_fk2
FOREIGN KEY (winner_team_id)
REFERENCES team (team_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE team_player ADD CONSTRAINT team_team_player_fk
FOREIGN KEY (team_id)
REFERENCES team (team_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match_event ADD CONSTRAINT team_match_event_fk
FOREIGN KEY (team_id)
REFERENCES team (team_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE season_competition ADD CONSTRAINT competition_season_competition_fk
FOREIGN KEY (competition_id)
REFERENCES competition (competition_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE season_competition ADD CONSTRAINT season_season_competition_fk
FOREIGN KEY (season_id)
REFERENCES season (season_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match ADD CONSTRAINT season_competition_match_fk
FOREIGN KEY (season_competition_id)
REFERENCES season_competition (season_competition_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE player_match ADD CONSTRAINT match_player_match_fk
FOREIGN KEY (match_id)
REFERENCES match (match_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE match_event ADD CONSTRAINT match_match_event_fk
FOREIGN KEY (match_id)
REFERENCES match (match_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION

ALTER TABLE tag_match_event ADD CONSTRAINT match_event_tag_match_event_fk
FOREIGN KEY (match_event_id)
REFERENCES match_event (match_event_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION