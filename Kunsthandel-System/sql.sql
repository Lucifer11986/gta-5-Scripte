CREATE TABLE IF NOT EXISTS art_trades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(255),
    art_name VARCHAR(255),
    price INT,
    is_stolen BOOLEAN,
    trade_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabelle für Kunstwerke
CREATE TABLE `artworks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `label` VARCHAR(255) NOT NULL,
    `price` INT NOT NULL,
    `is_forged` BOOLEAN DEFAULT 0,
    `image_url` VARCHAR(255)
);

-- Tabelle für Spielerbesitz von Kunstwerken
CREATE TABLE `player_artworks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `artwork_id` INT NOT NULL,
    `stored` BOOLEAN DEFAULT 0,
    FOREIGN KEY (`artwork_id`) REFERENCES `artworks`(`id`)
);
