CREATE TABLE IF NOT EXISTS `graffiti` (
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` VARCHAR(50) NOT NULL,
    `motif` VARCHAR(100) NOT NULL,
    `x` FLOAT NOT NULL,
    `y` FLOAT NOT NULL,
    `z` FLOAT NOT NULL,
    `color` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Spraydosen als Item
CREATE TABLE IF NOT EXISTS `items` (
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `weight` INT NOT NULL,
    `quantity` INT NOT NULL,
    `type` VARCHAR(100) NOT NULL
);

INSERT INTO `items` (`name`, `label`, `weight`, `quantity`, `type`) VALUES
('spray_can', 'Sprühdose', 1, 1, 'item');


INSERT INTO items (name, label, weight, rare, can_remove) VALUES
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
