CREATE TABLE `team_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;;

CREATE TABLE `team_registry` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `tag` VARCHAR(255) NOT NULL,
  `color` VARCHAR(1) NOT NULL,
  `type` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`type`) REFERENCES `team_type`(`id`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;;

CREATE TABLE `team_players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(255) NOT NULL,
  `team_id` int(11) NOT NULL,
  `team_type` VARCHAR(255) NOT NULL,
  `is_owner` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`team_id`) REFERENCES `team_registry`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`team_id`) REFERENCES `team_type`(`id`) ON DELETE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;;


INSERT INTO `team_type` (type) VALUES
('Drift'),
('Grip'),
('Off-Road');