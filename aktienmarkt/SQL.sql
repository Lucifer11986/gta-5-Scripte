-- Tabelle für Aktieninformationen, verknüpft mit items
CREATE TABLE IF NOT EXISTS stock_market (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    job_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabelle für den Benutzerbestand (optional, falls benötigt)
CREATE TABLE IF NOT EXISTS user_stocks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    stock_id INT NOT NULL,
    amount INT NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES stock_market(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Beispielhafte Daten für Aktien
INSERT INTO stock_market (item_id, job_id, price) VALUES
(1, 1, 100.00), -- Beispiel für Item-ID 1 und Job-ID 1
(2, 2, 200.00), -- Beispiel für Item-ID 2 und Job-ID 2
(3, 3, 150.00); -- Beispiel für Item-ID 3 und Job-ID 3
