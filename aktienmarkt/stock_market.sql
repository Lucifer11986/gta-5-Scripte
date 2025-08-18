-- Tabelle für Artikel (items) erstellen, falls sie noch nicht existiert
CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabelle für Jobs erstellen, falls sie noch nicht existiert
CREATE TABLE IF NOT EXISTS jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    label VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabelle für Aktieninformationen, verknüpft mit items und jobs
CREATE TABLE IF NOT EXISTS stock_market (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    job_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
) ENGINE=InnoDB;



-- Tabelle für den Benutzerbestand (optional, falls benötigt)
CREATE TABLE IF NOT EXISTS user_stocks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    stock_id INT NOT NULL,
    amount INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_id) REFERENCES stock_market(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Beispielhafte Daten für Items (Ressourcen)
INSERT INTO items (name, description, price) VALUES
('Gold', 'Ein wertvolles Metall.', 1500.00),
('Silber', 'Ein wertvolles Metall.', 25.00),
('Öl', 'Eine wichtige Ressource für die Industrie.', 65.00);

-- Beispielhafte Daten für Jobs
INSERT INTO jobs (name, label) VALUES
('miner', 'Bergarbeiter'),
('oilworker', 'Ölarbeiter'),
('jeweler', 'Juwelier');

-- Beispielhafte Daten für Aktien
INSERT INTO stock_market (item_id, job_id, price) VALUES
(1, 1, 100.00), -- Beispiel für Item-ID 1 (Gold) und Job-ID 1 (Bergarbeiter)
(2, 2, 200.00), -- Beispiel für Item-ID 2 (Silber) und Job-ID 2 (Ölarbeiter)
(3, 3, 150.00); -- Beispiel für Item-ID 3 (Öl) und Job-ID 3 (Juwelier)

SHOW CREATE TABLE items;
SHOW CREATE TABLE jobs;
