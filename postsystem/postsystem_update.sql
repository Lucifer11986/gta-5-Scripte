-- Tabelle für Pakete
CREATE TABLE IF NOT EXISTS `post_packages` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `sender_identifier` VARCHAR(60) DEFAULT NULL,
  `receiver_identifier` VARCHAR(60) DEFAULT NULL,
  `item_name` VARCHAR(50) NOT NULL,
  `item_count` INT(11) NOT NULL DEFAULT 1,
  `status` VARCHAR(50) NOT NULL DEFAULT 'pending', -- Mögliche Status: pending, in-transit, delivered, confiscated
  `assigned_postman` VARCHAR(60) DEFAULT NULL,
  `express` BOOLEAN NOT NULL DEFAULT FALSE,
  `creation_timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivery_mailbox_id` INT(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

-- Tabelle für Spieler-Briefkästen
CREATE TABLE IF NOT EXISTS `player_mailboxes` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `owner_identifier` VARCHAR(60) NOT NULL,
  `location` VARCHAR(255) NOT NULL, -- Speichert Koordinaten als JSON-String
  `inventory` LONGTEXT DEFAULT NULL, -- Speichert das Inventar als JSON-String
  PRIMARY KEY (`id`)
);

-- Neue Items hinzufügen (verhindert Fehler, falls sie bereits existieren)
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
  ('cardboard_box', 'Karton', 1, 0, 1),
  ('mailbox_item', 'Briefkasten', 10, 0, 1)
ON DUPLICATE KEY UPDATE `name`=`name`;

-- Fügen Sie diese Items nach Bedarf zu Ihren Shops hinzu. Beispiel:
-- INSERT INTO `shops` (`store`, `item`, `price`) VALUES
--   ('LTDgasoline', 'cardboard_box', 10),
--   ('RobsLiquor', 'mailbox_item', 250);
