-- Tabelle für Therapie-Sessions
CREATE TABLE IF NOT EXISTS rehab_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(50) NOT NULL,       -- Spieler-Identifikator
    start_time DATETIME NOT NULL,          -- Beginn der Therapie
    end_time DATETIME,                     -- Ende der Therapie
    session_cost INT NOT NULL,             -- Kosten der Therapie
    FOREIGN KEY (identifier) REFERENCES players(identifier) ON DELETE CASCADE
);
