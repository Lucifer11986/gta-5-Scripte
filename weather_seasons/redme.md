
# Weather & Seasons Plus

Dies ist ein umfassendes Skript für FiveM (ESX), das ein dynamisches Jahreszeiten- und Wettersystem mit tiefgreifenden Survival- und Event-Mechaniken implementiert, um die Immersion auf einem Rollenspiel-Server drastisch zu erhöhen.

## Features

### Dynamisches Jahreszeiten- & Wettersystem
- **4 Jahreszeiten:** Frühling, Sommer, Herbst und Winter.
- **Automatischer Wechsel:** Die Jahreszeiten wechseln automatisch nach einer in der `config.lua` festgelegten Dauer (`Config.SeasonDuration`).
- **Dynamische Temperatur:** Die Temperatur ändert sich dynamisch innerhalb jeder Jahreszeit in einem konfigurierbaren Intervall (`Config.TemperatureChangeIntervalMinutes`). Die min/max Temperaturen für jede Jahreszeit sind ebenfalls einstellbar.
- **Visuelle Effekte:** Jede Jahreszeit hat ihre eigenen visuellen Effekte, wie z.B. fallendes Laub im Herbst.

### Survival-System
- **Hitze-Effekte (Sommer):**
  - Bei hohen Temperaturen (`Config.Survival.HotTemperature`) verlieren Spieler an Durst.
  - Das Tragen von warmer Kleidung (`Config.WarmClothing`) beschleunigt den Durstverlust.
  - Bei 0 Durst erleidet der Spieler Hitzschlag-Schaden.
- **Kälte-Effekte (Winter):**
  - Bei niedrigen Temperaturen (`Config.Survival.ColdTemperature`) verlieren Spieler Leben durch Erfrieren.
  - Das Tragen von warmer Kleidung schützt vor dem Kälteschaden.
  - Spieler sind in geschlossenen Fahrzeugen (Autos/LKWs) und in Innenräumen (Interiors) vor der Kälte geschützt.
- **Debug-Befehl:** Mit `/myclothes` kann jeder Spieler die IDs seiner Kleidung in der F8-Konsole sehen, um die `Config.WarmClothing`-Liste einfach zu erweitern.

### Saisonale Sammel-Events
- **Oster-Event (Frühling):** Spieler können Ostereier suchen, um Belohnungen zu erhalten. Das Event ist nur im Frühling aktiv.
- **Herbst-Event (Kürbissuche):** Spieler können Kürbisse suchen. Das Event läuft für eine konfigurierbare Anzahl von Tagen (`Config.AutumnEvent.DurationDays`).
- **Winter-Event (Geschenkesuche):** Spieler können Geschenke suchen. Das Event läuft für eine konfigurierbare Anzahl von Tagen (`Config.WinterEvent.DurationDays`).
- **Seltenheits-System:** Die Belohnungen für die Herbst- und Winter-Events sind in `common`, `rare` und `very_rare` unterteilt, mit einstellbaren Wahrscheinlichkeiten.

### Dynamische Wetter-Events
Ein Event-System, das zufällige, wetterabhängige Mini-Events auslösen kann.
- **Stromausfall:** Bei Gewitter besteht die Chance auf einen Stromausfall in einem zufälligen Stadtteil.
- **Buschfeuer:** Bei Hitzewellen besteht die Chance, dass ein Feuer im ländlichen Raum ausbricht.
- **Blizzard:** Bei Schneestürmen können Straßen blockiert werden (wird auf der Karte angezeigt).

### Schneeketten-System (Winter)
- **Item:** Ein benutzbares Item `snow_chains` (muss zur Datenbank hinzugefügt werden).
- **Funktion:** Verbessert den Grip von Fahrzeugen auf vereisten Straßen im Winter.
- **Anwendung:** Benötigt eine bestimmte Anzahl von Ketten je nach Fahrzeugtyp (Auto, LKW, Motorrad).
- **Haltbarkeit:** Die Ketten gehen nach einer konfigurierbaren Zeit (`Config.SnowChains.DurabilityMinutes`) kaputt.
- **Interaktion:** Spieler können die Ketten interaktiv am Fahrzeug anbringen und wieder entfernen.
- **Strafe:** Das Anbringen von Schneeketten außerhalb des Winters zerstört die Reifen des Fahrzeugs.

## Konfiguration
Das gesamte Skript ist über die `config.lua`-Datei hochgradig anpassbar. Fast jeder Wert, von Event-Wahrscheinlichkeiten über Belohnungen bis hin zu Schadenswerten, kann dort eingestellt werden.

## Installation & Abhängigkeiten
1.  Stelle sicher, dass die Ressource nach den Abhängigkeiten gestartet wird.
2.  Füge das `snow_chains`-Item zu deiner `items`-Tabelle in der Datenbank hinzu.
3.  Passe die `config.lua` nach deinen Wünschen an.

**Abhängigkeiten:**
- `es_extended`
- `oxmysql`

# Weather & Seasons Plus

Dies ist ein umfassendes Skript für FiveM (ESX), das ein dynamisches Jahreszeiten- und Wettersystem mit tiefgreifenden Survival- und Event-Mechaniken implementiert, um die Immersion auf einem Rollenspiel-Server drastisch zu erhöhen.

## Features

### Dynamisches Jahreszeiten- & Wettersystem
- **4 Jahreszeiten:** Frühling, Sommer, Herbst und Winter.
- **Automatischer Wechsel:** Die Jahreszeiten wechseln automatisch nach einer in der `config.lua` festgelegten Dauer (`Config.SeasonDuration`).
- **Dynamische Temperatur:** Die Temperatur ändert sich dynamisch innerhalb jeder Jahreszeit in einem konfigurierbaren Intervall (`Config.TemperatureChangeIntervalMinutes`). Die min/max Temperaturen für jede Jahreszeit sind ebenfalls einstellbar.
- **Visuelle Effekte:** Jede Jahreszeit hat ihre eigenen visuellen Effekte, wie z.B. fallendes Laub im Herbst.

### Survival-System
- **Hitze-Effekte (Sommer):**
  - Bei hohen Temperaturen (`Config.Survival.HotTemperature`) verlieren Spieler an Durst.
  - Das Tragen von warmer Kleidung (`Config.WarmClothing`) beschleunigt den Durstverlust.
  - Bei 0 Durst erleidet der Spieler Hitzschlag-Schaden.
- **Kälte-Effekte (Winter):**
  - Bei niedrigen Temperaturen (`Config.Survival.ColdTemperature`) verlieren Spieler Leben durch Erfrieren.
  - Das Tragen von warmer Kleidung schützt vor dem Kälteschaden.
  - Spieler sind in geschlossenen Fahrzeugen (Autos/LKWs) und in Innenräumen (Interiors) vor der Kälte geschützt.
- **Debug-Befehl:** Mit `/myclothes` kann jeder Spieler die IDs seiner Kleidung in der F8-Konsole sehen, um die `Config.WarmClothing`-Liste einfach zu erweitern.

### Saisonale Sammel-Events
- **Oster-Event (Frühling):** Spieler können Ostereier suchen, um Belohnungen zu erhalten. Das Event ist nur im Frühling aktiv.
- **Herbst-Event (Kürbissuche):** Spieler können Kürbisse suchen. Das Event läuft für eine konfigurierbare Anzahl von Tagen (`Config.AutumnEvent.DurationDays`).
- **Winter-Event (Geschenkesuche):** Spieler können Geschenke suchen. Das Event läuft für eine konfigurierbare Anzahl von Tagen (`Config.WinterEvent.DurationDays`).
- **Seltenheits-System:** Die Belohnungen für die Herbst- und Winter-Events sind in `common`, `rare` und `very_rare` unterteilt, mit einstellbaren Wahrscheinlichkeiten.

### Dynamische Wetter-Events
Ein Event-System, das zufällige, wetterabhängige Mini-Events auslösen kann.
- **Stromausfall:** Bei Gewitter besteht die Chance auf einen Stromausfall in einem zufälligen Stadtteil.
- **Buschfeuer:** Bei Hitzewellen besteht die Chance, dass ein Feuer im ländlichen Raum ausbricht.
- **Blizzard:** Bei Schneestürmen können Straßen blockiert werden (wird auf der Karte angezeigt).

### Schneeketten-System (Winter)
- **Item:** Ein benutzbares Item `snow_chains` (muss zur Datenbank hinzugefügt werden).
- **Funktion:** Verbessert den Grip von Fahrzeugen auf vereisten Straßen im Winter.
- **Anwendung:** Benötigt eine bestimmte Anzahl von Ketten je nach Fahrzeugtyp (Auto, LKW, Motorrad).
- **Haltbarkeit:** Die Ketten gehen nach einer konfigurierbaren Zeit (`Config.SnowChains.DurabilityMinutes`) kaputt.
- **Interaktion:** Spieler können die Ketten interaktiv am Fahrzeug anbringen und wieder entfernen.
- **Strafe:** Das Anbringen von Schneeketten außerhalb des Winters zerstört die Reifen des Fahrzeugs.

## Konfiguration
Das gesamte Skript ist über die `config.lua`-Datei hochgradig anpassbar. Fast jeder Wert, von Event-Wahrscheinlichkeiten über Belohnungen bis hin zu Schadenswerten, kann dort eingestellt werden.

## Installation & Abhängigkeiten
1.  Stelle sicher, dass die Ressource nach den Abhängigkeiten gestartet wird.
2.  Füge das `snow_chains`-Item zu deiner `items`-Tabelle in der Datenbank hinzu.
3.  Passe die `config.lua` nach deinen Wünschen an.

**Abhängigkeiten:**
- `es_extended`
- `oxmysql`

