# Drogensucht Script für FiveM

## 🚀 Übersicht
Dieses Script für FiveM bietet ein immersives Drogensucht-System für Roleplay-Server. Es ermöglicht den Spielern, Drogen zu konsumieren, Suchtlevel zu entwickeln und mit den Auswirkungen der Drogensucht zu kämpfen. Zusätzlich können Spieler sich einer Therapie unterziehen, um ihre Sucht zu überwinden und die Auswirkungen der Entzugserscheinungen zu erleiden.

## ⚡ Features
- **Drogensucht-System:**
  - Konsum von Drogen führt zu einem steigenden Suchtlevel.
  - Jede Droge hat einzigartige Effekte (z.B. LSD, Meth, Ecstasy).
  - Dynamische Auswirkungen wie veränderte Bildschirmdarstellungen und Bewegungsmodifikationen.
  
- **Entzugserscheinungen:**
  - Spieler erleben Symptome wie verschwommenes Sehen, langsames Gehen und HP-Verlust, wenn sie zu lange ohne Drogen auskommen.
  
- **Therapie:**
  - Spieler können sich bei einem Arzt behandeln lassen, um ihre Sucht zu heilen.
  - Die Therapie hat einen Preis und eine Wartezeit, nach der das Suchtlevel zurückgesetzt wird.
  
- **Datenbankunterstützung:**
  - Alle Transaktionen (z.B. Drogeneinkäufe, Therapiekosten) werden gespeichert.
  - Speicherung von Drogenkonsumverhalten und Suchtlevel in einer SQL-Datenbank.

- **Modularer Code:**
  - Flexibel erweiterbar und einfach anpassbar durch Konfigurationsdateien.
  - Unterstützung für verschiedene Frameworks (ESX, ESY, QB-Core).

## 🛠 Installation

### 1. Ressourcen-Struktur
Lade das Script in deinen `resources`-Ordner auf deinem FiveM-Server hoch und stelle sicher, dass die Verzeichnisse wie folgt angeordnet sind:

resources/ 
      └── drug_addiction/ 
        ├── client/ │
          ├── drug_use.lua │ 
          ├── effects.lua 
        ├── server/ │ 
          ├── main.lua │ 
          ├── transactions.lua 
        ├── shared/ │ 
        ├── config.lua 
      ├── sql/ │ 
        ├── schema.sql 
      └── fxmanifest.lua

      
### 2. Datenbank
Erstelle die benötigten Tabellen in deiner MySQL-Datenbank, indem du die SQL-Skripte aus der `sql/schema.sql` Datei ausführst.

```sql
CREATE TABLE IF NOT EXISTS `addiction_data` (
    `identifier` VARCHAR(50) PRIMARY KEY,
    `addiction_level` INT NOT NULL DEFAULT 0,
    `last_drug` VARCHAR(50) NULL,
    `last_used` DATETIME NULL
);

CREATE TABLE IF NOT EXISTS `transactions` (
    `transaction_id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `drug` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `rehab_sessions` (
    `session_id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(50) NOT NULL,
    `start_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `end_time` DATETIME NULL,
    `cost` INT NOT NULL
);


3. Server Konfiguration
Bearbeite die Datei shared/config.lua, um die Preise, Effekte und andere Parameter wie folgt anzupassen:

Config = {}

Config.Drugs = {
    cocaine = { addictionRate = 20, price = 500, effectDuration = 15000 },
    lsd = { addictionRate = 15, price = 400, effectDuration = 20000 },
    meth = { addictionRate = 25, price = 600, effectDuration = 12000 },
    ecstasy = { addictionRate = 18, price = 450, effectDuration = 13000 },
    heroin = { addictionRate = 30, price = 700, effectDuration = 14000 },
    mushrooms = { addictionRate = 10, price = 300, effectDuration = 16000 }
}

Config.MaxAddictionLevel = 100
Config.RehabCost = 1000
Config.RehabTime = 30 -- in Minuten
Config.WithdrawalStartLevel = 40

Config.WithdrawalEffects = {
    blur = true,
    shaking = true,
    movementSlow = true,
    healthLoss = true
}

4. Client & Server Setup
Stelle sicher, dass die richtigen Framework-Events auf deinem Server konfiguriert sind, um mit ESX, ESY oder QB-Core zu arbeiten.
Überprüfe die Client-Dateien, insbesondere client/drug_use.lua und client/effects.lua, um sicherzustellen, dass alle Drogeneffekte korrekt angewendet werden.

5. Einbinden und Aktivieren
Füge das Script in deiner server.cfg hinzu:

ensure drug_addiction

🔧 Anpassungen & Erweiterungen

Drogenarten hinzufügen: Du kannst in der shared/config.lua neue Drogenarten hinzufügen, die spezifische Effekte haben.
Therapie-Anpassungen: Ändere den Preis oder die Dauer der Therapie im Config.RehabCost und Config.RehabTime.
Entzugserscheinungen: Du kannst die Entzugserscheinungen anpassen, indem du die Optionen im Config.WithdrawalEffects bearbeitest.

📜 Changelog
Version 1.0: Initial Release
Drogensucht-System hinzugefügt, inklusive Suchtlevel, Drogeneffekten und Therapie.
Datenbank-Tabellen für Transaktionen und Suchtlevel erstellt.
Implementierung der Drogeneffekte und Entzugserscheinungen.

🎮 Wie man spielt
Drogen konsumieren: Benutze die entsprechenden Befehle oder Events, um Drogen zu konsumieren und ihre Effekte zu erleben.
Therapie beginnen: Besuche einen Arzt und lasse dich behandeln, um deine Sucht zu überwinden.
Werte im HUD: Überwache dein Suchtlevel und deine Gesundheitswerte im HUD (coming soon).