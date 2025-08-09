-- Tabelle für die verfügbaren Kunstwerke
CREATE TABLE `artworks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `label` VARCHAR(255) NOT NULL,
    `price` INT NOT NULL,
    `is_forged` BOOLEAN DEFAULT 0,
    `image_url` VARCHAR(255)
);

-- Tabelle, die den Besitz von Kunstwerken durch Spieler verfolgt
CREATE TABLE `player_artworks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `artwork_id` INT NOT NULL,
    `stored` BOOLEAN DEFAULT 0,
    FOREIGN KEY (`artwork_id`) REFERENCES `artworks`(`id`)
);

-- Beispiel-Kunstwerke einfügen
INSERT INTO `artworks` (`name`, `label`, `price`, `image_url`) VALUES
('monalisa', 'Mona Lisa', 50000, 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/687px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg'),
('sternennacht', 'Sternennacht', 75000, 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/757px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg');
