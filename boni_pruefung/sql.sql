-- SQL-Setup für das Spieler-Bonitätssystem

-- Spalten zu bestehender 'users'-Tabelle hinzufügen
ALTER TABLE `users`
ADD COLUMN `credit_score` INT DEFAULT 500,
ADD COLUMN `outstanding_loans` INT DEFAULT 0,
ADD COLUMN `missed_payments` INT DEFAULT 0,
ADD COLUMN `insurance` VARCHAR(50) DEFAULT 'Keine';

-- Tabelle für Kredittransaktionen erstellen
CREATE TABLE IF NOT EXISTS `loan_transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `interest_rate` FLOAT NOT NULL,
    `total_repayment` INT NOT NULL,
    `remaining_balance` INT NOT NULL,
    `due_date` DATE NOT NULL,
    `status` ENUM('laufend', 'bezahlt', 'verpasst') DEFAULT 'laufend',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabelle für Versicherungsdaten erstellen
CREATE TABLE IF NOT EXISTS `insurance_policies` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `policy_type` VARCHAR(50) NOT NULL,
    `premium` INT NOT NULL,
    `coverage` INT NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `status` ENUM('aktiv', 'abgelaufen') DEFAULT 'aktiv',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Beispiel-Daten für Versicherungen (optional)
INSERT INTO `insurance_policies` (`identifier`, `policy_type`, `premium`, `coverage`, `start_date`, `end_date`)
VALUES
('char1:10d24a7f71b693d9f417f7ebd58c17fe648516e5', 'Kfz-Versicherung', 200, 10000, '2025-01-01', '2026-01-01');

-- Beispiel für einen Kredit (optional)
INSERT INTO `loan_transactions` (`identifier`, `amount`, `interest_rate`, `total_repayment`, `remaining_balance`, `due_date`)
VALUES
('char1:10d24a7f71b693d9f417f7ebd58c17fe648516e5', 5000, 5.5, 5275, 5275, '2025-12-31');
