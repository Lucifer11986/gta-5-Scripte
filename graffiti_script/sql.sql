-- This table stores the placed graffiti in the world.
-- The schema is updated to match the data being sent from graffiti_management.lua
CREATE TABLE IF NOT EXISTS `graffiti` (
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `x` FLOAT NOT NULL,
    `y` FLOAT NOT NULL,
    `z` FLOAT NOT NULL,
    `heading` FLOAT NOT NULL,
    `color` VARCHAR(50) NOT NULL,
    `image` VARCHAR(100) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- This table adds the spray can items to the database for ESX.
-- The schema has been consolidated to the standard ESX format.
-- The old, incorrect CREATE TABLE and INSERT statements have been removed.
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('spraycan_red', 'Rote Spraydose', 1, 0, 1),
('spraycan_blue', 'Blaue Spraydose', 1, 0, 1),
('spraycan_green', 'Grüne Spraydose', 1, 0, 1),
('spraycan_yellow', 'Gelbe Spraydose', 1, 0, 1),
('spraycan_orange', 'Orange Spraydose', 1, 0, 1),
('spraycan_purple', 'Violette Spraydose', 1, 0, 1),
('spraycan_pink', 'Pinke Spraydose', 1, 0, 1),
('spraycan_black', 'Schwarze Spraydose', 1, 0, 1),
('spraycan_white', 'Weiße Spraydose', 1, 0, 1),
('spraycan_grey', 'Graue Spraydose', 1, 0, 1),
('spraycan_brown', 'Braune Spraydose', 1, 0, 1),
('spraycan_cyan', 'Cyan Spraydose', 1, 0, 1),
('spraycan_magenta', 'Magenta Spraydose', 1, 0, 1),
('spraycan_turquoise', 'Türkise Spraydose', 1, 0, 1),
('spraycan_lime', 'Limettengrüne Spraydose', 1, 0, 1),
('spraycan_gold', 'Goldene Spraydose', 1, 1, 1),
('spraycan_silver', 'Silberne Spraydose', 1, 1, 1),
('spraycan_chrome', 'Chrom Spraydose', 1, 1, 1),
('spraycan_holographic', 'Holographische Spraydose', 1, 1, 1),
('spraycan_fire', 'Feuer Spraydose', 1, 1, 1);
