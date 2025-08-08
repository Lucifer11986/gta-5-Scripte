# 📮 PostSystem für FiveM

Das **PostSystem** ist ein umfassendes Script für FiveM, das Spielern ermöglicht, Nachrichten zu senden, Schließfächer zu kaufen und zu verwalten sowie Briefmarken zu verwenden. Es fügt eine realistische Poststation-Mechanik in deinen Server ein und verbessert die Interaktion zwischen den Spielern.

---

## ✉️ Funktionen

- **Nachrichten senden** – Spieler können Nachrichten an andere Spieler versenden.
- **Express-Versand** – Schnellere Lieferung gegen zusätzliche Gebühren.
- **Briefmarken-System** – Zum Versenden von Nachrichten werden Briefmarken benötigt.
- **Postfach-Kapazität** – Begrenzte Anzahl speicherbarer Nachrichten.
- **Schließfächer** – Spieler können eigene Schließfächer kaufen und verwalten.
- **Antworten auf Nachrichten** – Spieler können direkt auf erhaltene Nachrichten antworten.
- **Poststationen** – Auf der Karte markierte Orte bieten Zugang zum Postsystem.
- **Benachrichtigungen** – Spieler erhalten Hinweise auf neue Nachrichten.

---

## 🛠️ Installation

### ✅ Voraussetzungen

- **ESX** (getestet mit ESX 1.2 und neuer)
- **oxmysql** (für die Datenbankverbindung)

### 📂 Schritte

1. **Script herunterladen**
   - Lade das **PostSystem-Script** herunter und platziere es im `resources`-Ordner.
   - Benenne den Ordner in `postsystem` um.

2. **Datenbank einrichten**
   - Das Skript enthält eine `sql.sql`-Datei, die beim Serverstart automatisch ausgeführt werden sollte, um die notwendigen Datenbank-Tabellen zu erstellen.
   - Falls die automatische Einrichtung fehlschlägt, führe die folgenden SQL-Befehle manuell in deiner Datenbank aus:

   ```sql
   CREATE TABLE IF NOT EXISTS `post_messages` (
     `id` INT(11) NOT NULL AUTO_INCREMENT,
     `sender_identifier` VARCHAR(60) DEFAULT NULL,
     `sender_name` VARCHAR(255) NOT NULL,
     `receiver_identifier` VARCHAR(60) NOT NULL,
     `message` TEXT NOT NULL,
     `express` BOOLEAN NOT NULL DEFAULT FALSE,
     `station` VARCHAR(255) DEFAULT NULL,
     `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     `is_read` BOOLEAN NOT NULL DEFAULT FALSE,
     PRIMARY KEY (`id`)
   );

   CREATE TABLE IF NOT EXISTS `user_lockers` (
       `id` INT AUTO_INCREMENT PRIMARY KEY,
       `identifier` VARCHAR(255) NOT NULL,
       `locker_id` VARCHAR(255) NOT NULL,
       `purchased` TINYINT(1) DEFAULT 0,
       UNIQUE KEY `unique_combination` (`identifier`, `locker_id`)
   );

   INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
   ('stamp', 'Briefmarke', 1, 0, 1);

   INSERT INTO `shops` (`store`, `item`, `price`) VALUES
   ('Supermarkt', 'stamp', 50);
   ```

3. **Script starten**
   - Füge folgende Zeile in die `server.cfg` ein:
     ```cfg
     ensure postsystem
     ```

4. **Konfiguration anpassen**
   - Bearbeite die `config.lua`, um Poststationen, Schließfächer und Gebühren anzupassen.

---

## 🎮 Verwendung

### 🎛️ Tastenbelegung
- **E** – Postsystem öffnen (bei einer Poststation).
- **F5** – Schließfach öffnen (bei einem Schließfach).
- **F6** – Schließfach kaufen (bei einer Poststation).

### 📩 Nachrichten senden
1. Gehe zu einer **Poststation**.
2. Drücke **E**, um das **Postsystem** zu öffnen.
3. Wähle eine **Poststation**, einen **Empfänger** und schreibe deine Nachricht.
4. Wähle **Express-Versand** (optional).
5. Sende die Nachricht.

### 🔒 Schließfächer
1. Gehe zu einer **Poststation**.
2. Drücke **F6**, um ein **Schließfach zu kaufen**.
3. Gehe zu deinem **Schließfach** und drücke **F5**, um es zu öffnen.

### 📨 Auf Nachrichten antworten
1. Öffne das **Postsystem**.
2. Wähle eine Nachricht aus deinem **Posteingang**.
3. Klicke auf **Antworten**, um eine **Antwort zu senden**.

---

## ⚙️ Konfiguration (`config.lua`)

### 🏤 **Poststationen**
```lua
Config.PostStations = {
    {x = -422.74, y = 6136.32, z = 30.87, heading = 229.28, name = "Paleto Post Office"},
    {x = 1704.15, y = 3779.58, z = 33.75, heading = 208.11, name = "Sandy Post Office"},
    {x = 380.51, y = -833.32, z = 28.29, heading = 176.35, name = "City Post Office"}
}
```

### 🔐 **Schließfächer**
```lua
Config.Lockers = {
    {id = "Schließfach Frachthafen", x = 1048.65, y = -2995.0, z = 5.9, name = "Schließfach 1"},
    {id = "Schließfach Paleto", x = -406.64, y = 6150.92, z = 31.68, name = "Schließfach 2"}
}
```

### 🗺️ **Blip-Einstellungen**
```lua
Config.BlipSettings = {
    sprite = 280,
    color = 2,
    scale = 0.8
}
```

### 📬 **Sonstige Einstellungen**
```lua
Config.NotificationDuration = 5000 -- Benachrichtigungsdauer
Config.DeliveryFee = 100 -- Standardgebühr für den Versand
Config.ExpressMultiplier = 3 -- Expressversand kostet das Dreifache
Config.ExpressDeliveryTime = 5 -- Express-Mail Zustellung in Sekunden
Config.StandardDeliveryTime = 120 -- Standard-Mail Zustellung in Sekunden
Config.StampPrice = 50 -- Preis für eine Briefmarke
Config.StampItem = "stamp" -- Item-Name für Briefmarken
Config.MailboxCapacity = 20 -- Maximale Nachrichtenanzahl pro Spieler
Config.LockerCapacity = 10 -- Maximale Gegenstände pro Schließfach
Config.LockerCost = 500 -- Kosten für ein Schließfach
```

---

## 🖼️ Briefmarken-Item einrichten

### 1️⃣ **Item-Bild (`stamp.png`) hinzufügen**
Falls du ein Inventar mit Bildern verwendest, füge `stamp.png` in das richtige Verzeichnis ein:

**Für `esx_inventoryhud`**:
- `html/img/items/`

**Für `qs-inventory`**:
- `html/images/`

### 2️⃣ **Item in die Datenbank einfügen**
Führe diesen SQL-Befehl aus:
```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('stamp', 'Briefmarke', 1, 0, 1);
```

### 3️⃣ **Item in den Shop einfügen (optional)**
Falls Briefmarken im Supermarkt verkauft werden sollen, nutze diesen SQL-Befehl:
```sql
INSERT INTO `shops` (`store`, `item`, `price`) VALUES
('Supermarkt', 'stamp', 50);
```
