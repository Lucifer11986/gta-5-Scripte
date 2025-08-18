CREATE TABLE IF NOT EXISTS `stocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `label` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_stocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `stock_name` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `player_stock_unique` (`identifier`,`stock_name`),
  KEY `fk_player_stocks_stocks` (`stock_name`),
  CONSTRAINT `fk_player_stocks_stocks` FOREIGN KEY (`stock_name`) REFERENCES `stocks` (`name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT INTO `stocks` (`name`, `label`, `category`, `price`) VALUES
	('ammu', 'Ammu-Nation', 'firmen', 120),
	('ls_customs', 'Los Santos Customs', 'firmen', 150),
	('epsilon', 'Epsilon Program', 'firmen', 250),
	('gold', 'Gold', 'rohstoffe', 500),
	('silber', 'Silber', 'rohstoffe', 250),
	('oel', 'Öl', 'rohstoffe', 180),
	('eisen', 'Eisen', 'materialien', 80),
	('kupfer', 'Kupfer', 'materialien', 60),
	('aluminium', 'Aluminium', 'materialien', 70);
