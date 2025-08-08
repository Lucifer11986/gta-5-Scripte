-- Tabelle für die Speicherung der Drogenabhängigkeit der Spieler
CREATE TABLE IF NOT EXISTS addiction_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(50) NOT NULL,   -- Spieler-Identifikator
    addiction_level INT NOT NULL,      -- Level der Sucht (z.B. 0 bis 100)
    last_used DATETIME NOT NULL,       -- Datum und Uhrzeit des letzten Drogenkonsums
    last_rehab DATETIME,               -- Datum und Uhrzeit der letzten Therapie
    FOREIGN KEY (identifier) REFERENCES users(identifier) ON DELETE CASCADE
);
