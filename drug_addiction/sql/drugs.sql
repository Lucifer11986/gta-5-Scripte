-- Tabelle für Drogen
CREATE TABLE IF NOT EXISTS drugs (
    name VARCHAR(50) PRIMARY KEY,           -- Name der Droge (z.B. 'cocaine', 'lsd', 'meth')
    price INT NOT NULL,                     -- Preis der Droge
    effect_description TEXT NOT NULL,       -- Beschreibung der Drogeneffekte (z.B. 'Speed', 'Hallucinations')
    legality ENUM('illegal', 'legal') NOT NULL,  -- Legaler Status der Droge
    addictiveness_level INT NOT NULL        -- Suchtpotenzial der Droge (0 - 100)
);
