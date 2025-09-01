-- Autobauer Job Script - Datenbanktabellen
-- Erstellt alle benötigten Tabellen für Materiallager, Fahrzeuglager, Mitarbeiter und Autohaus

-- 1. Materiallager
CREATE TABLE IF NOT EXISTS `job_storage_materials` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `item_name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    `quantity` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Fahrzeuglager
CREATE TABLE IF NOT EXISTS `job_storage_cars` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `vehicle_name` VARCHAR(50) NOT NULL,
    `plate` VARCHAR(10) UNIQUE,
    `status` ENUM('stored','delivering') DEFAULT 'stored',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Job-Mitarbeiter
CREATE TABLE IF NOT EXISTS `job_employees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `job_rank` INT DEFAULT 1,        -- 1 = Mitarbeiter, 2 = Supervisor/Boss
    `active` BOOLEAN DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Autohaus Fahrzeuge
CREATE TABLE IF NOT EXISTS `car_stock` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `vehicle_name` VARCHAR(50) NOT NULL,
    `plate` VARCHAR(10) UNIQUE,
    `price` INT NOT NULL,
    `owner` VARCHAR(50) DEFAULT 'dealership',
    `sold` BOOLEAN DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Optional: Erweiterung der vorhandenen Fahrzeuge-Tabelle
-- ALTER TABLE `vehicles`
-- ADD COLUMN `garage` VARCHAR(50) DEFAULT 'player',
-- ADD COLUMN `job_source` VARCHAR(50) DEFAULT NULL;

-- 6. Beispiel: Materialien einfügen
INSERT INTO `job_storage_materials` (`item_name`, `label`, `quantity`) VALUES
('iron', 'Eisenbarren', 100),
('rubber', 'Gummi', 50),
('leather', 'Leder', 40),
('electronics', 'Elektroteile', 30),
('fabric_red', 'Roter Stoff', 20);

-- 7. Beispiel: Autohaus Fahrzeuge (leer)
INSERT INTO `car_stock` (`vehicle_name`, `plate`, `price`, `owner`, `sold`) VALUES
('adder', 'AUTO001', 500000, 'dealership', 0),
('zentorno', 'AUTO002', 750000, 'dealership', 0);


ALTER TABLE vehicle_storage ADD COLUMN fuel_type ENUM('Super','Diesel','Elektro') NOT NULL DEFAULT 'Super';
ALTER TABLE player_vehicles ADD COLUMN fuel_type ENUM('Super','Diesel','Elektro') NOT NULL DEFAULT 'Super';
