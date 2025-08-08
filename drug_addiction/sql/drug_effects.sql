-- Tabelle für die Speicherung der Drogeneffekte
CREATE TABLE IF NOT EXISTS drug_effects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    drug_name VARCHAR(50) NOT NULL,         -- Name der Droge (z.B. 'cocaine', 'heroin')
    effect_type VARCHAR(50) NOT NULL,       -- Art des Effekts (z.B. 'speed', 'visual')
    effect_value FLOAT NOT NULL,           -- Wert des Effekts (z.B. die Geschwindigkeit oder Stärke der visuellen Effekte)
    duration INT NOT NULL,                 -- Dauer des Effekts in Sekunden
    FOREIGN KEY (drug_name) REFERENCES drugs(name) ON DELETE CASCADE
);
