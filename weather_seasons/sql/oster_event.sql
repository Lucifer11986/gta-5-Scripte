CREATE TABLE IF NOT EXISTS `easter_eggs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `egg_id` INT NOT NULL,
    `player_id` VARCHAR(255) NOT NULL,
    `finder_identifier` VARCHAR(255) NULL DEFAULT NULL,
    `found_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
