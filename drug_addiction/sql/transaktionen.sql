-- Tabelle für Transaktionen
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,        -- Typ der Transaktion (z.B. 'Drug Purchase' oder 'Rehab')
    amount INT NOT NULL,              -- Betrag der Transaktion
    details TEXT NOT NULL,           -- Details der Transaktion
    date DATETIME NOT NULL           -- Datum und Uhrzeit der Transaktion
);
