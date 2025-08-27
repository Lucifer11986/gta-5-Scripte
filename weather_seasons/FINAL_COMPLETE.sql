-- =================================================================
--      VOLLSTÄNDIGES SQL-SETUP FÜR weather_seasons (v4.0)
-- =================================================================
-- Dieses Skript enthält alle notwendigen Tabellen für den Betrieb.
-- Führen Sie diesen Code in Ihrer Datenbank aus (z.B. HeidiSQL, phpMyAdmin).
-- =================================================================

-- --------------------------------------------------------
-- Tabelle für die Kern-Logik (Jahreszeiten-Speicherung)
-- (Benötigt von server/server.lua)
--
CREATE TABLE IF NOT EXISTS `weather_seasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `season` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Initialer Eintrag, damit die Tabelle nicht leer ist
INSERT IGNORE INTO `weather_seasons` (`id`, `season`) VALUES (1, 'Frühling');


-- --------------------------------------------------------
-- Tabelle für das Pflanzen-System
-- (aus server/plant_growth.lua)
--
CREATE TABLE IF NOT EXISTS `plants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plant_name` varchar(255) DEFAULT NULL,
  `growth` int(11) DEFAULT NULL,
  `water` int(11) DEFAULT NULL,
  `health` int(11) DEFAULT NULL,
  `base_growth_rate` int(11) DEFAULT NULL,
  `last_growth_time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabellen für das Oster-Event
-- (aus server/oster_event.lua)
--
CREATE TABLE IF NOT EXISTS `easter_eggs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `egg_id` int(11) NOT NULL,
  `player_id` varchar(255) NOT NULL,
  `found_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `easter_eggs_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabellen für das Herbst-Event
-- (aus server/autumn_event.lua)
--
CREATE TABLE IF NOT EXISTS `autumn_pumpkins_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `event_timers` (
  `event_name` varchar(50) NOT NULL,
  `event_start_time` int(11) NOT NULL,
  PRIMARY KEY (`event_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabelle für das Winter-Event
-- (aus server/winter_event.lua)
--
CREATE TABLE IF NOT EXISTS `winter_presents_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------
-- Tabelle für das Sommer-Event
-- (aus server/sommer_events.lua)
--
CREATE TABLE IF NOT EXISTS `sommer_rangliste` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` varchar(255) DEFAULT NULL,
  `score` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =================================================================
--                  WICHTIGE ITEMS FÜR DIE DATENBANK
-- =================================================================
-- Diese müssen in deiner 'items'-Tabelle sein.
-- Wenn du ox_inventory verwendest, musst du sie dort in der items.lua eintragen.
-- Die Werte hier sind nur Beispiele!
-- -----------------------------------------------------------------

INSERT INTO `items` (`name`, `label`, `weight`) VALUES
	('snow_chains', 'Schneeketten', 2000),
	('watering_can', 'Gießkanne', 1500),
	('water_bottle', 'Wasserflasche', 500),
	('fertilizer', 'Dünger', 1000),
    ('pumpkin_pie', 'Kürbiskuchen', 500),
    ('scary_mask', 'Gruselmaske', 100),
    ('hot_chocolate', 'Heiße Schokolade', 300),
    ('christmas_sweater', 'Weihnachtspullover', 800)
ON DUPLICATE KEY UPDATE `label`=VALUES(`label`);
