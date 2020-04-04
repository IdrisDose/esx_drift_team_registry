/*change to whatever Database name you used.*/

USE `sesx`;

CREATE TABLE `team_registry` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`tag` VARCHAR(255) NOT NULL,
	`color` VARCHAR(1) NOT NULL,
	`type` VARCHAR(255) NOT NULL DEFAULT 'drift',
	PRIMARY KEY (`id`)
);

CREATE TABLE `team_players` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`steam_id` VARCHAR(255) NOT NULL
	`team_id` int(11) NOT NULL,
	`team_type` VARCHAR(255) NOT NULL,
	`is_owner` int(1) NOT NULL default '0',
	PRIMARY KEY (`id`)
)