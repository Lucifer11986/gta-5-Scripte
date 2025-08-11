# Kunsthandel-System für FiveM

**Version:** 3.0.0 (Überarbeitet von Jules)

Dieses Skript fügt ein umfassendes Kunsthandel-System zu deinem FiveM-Server hinzu, das sowohl für ESX als auch für QBCore (mit Einschränkungen) geeignet ist.

## Übersicht der Verbesserungen

Diese Version wurde grundlegend überarbeitet, um zahlreiche Fehler zu beheben, die Code-Qualität zu verbessern und die Konfigurierbarkeit zu erhöhen.

- **Stabilität:** Kritische Fehler, die das Kaufen und Verkaufen von Kunst verhinderten, wurden behoben.
- **Benutzerfreundlichkeit:** Händler werden nun mit 3D-Markern und optionalen Karten-Blips angezeigt. Die Interaktion erfolgt per Tastendruck.
- **Konfigurierbarkeit:** Nahezu alle Aspekte des Skripts (Händler-Standorte, Preise, Rabatte, Blips, Tasten) können nun einfach in der `config.lua` angepasst werden.
- **Code-Qualität:** Veralteter Code wurde entfernt, die Kompatibilität verbessert und die Dateistruktur aufgeräumt.

## Installation

1.  Lade das Skript herunter und füge den `Kunsthandel-System`-Ordner in den `resources`-Ordner deines FiveM-Servers ein.
2.  Passe die `config.lua` an deine Bedürfnisse an. Wähle dein Framework (`esx` oder `qb`) und konfiguriere die Händler.
3.  Führe die `sql.sql`-Datei in deiner Datenbank aus, um die notwendigen Tabellen zu erstellen und mit Beispiel-Kunstwerken zu füllen.
4.  Füge `ensure Kunsthandel-System` in deiner `server.cfg` hinzu.

## Funktionsweise

- **Kunstmärkte:** Spieler können an den in der `config.lua` definierten Orten Kunstwerke kaufen und verkaufen.
- **Legale & Illegale Märkte:** Du kannst Märkte als `legal` oder `illegal` kennzeichnen. Nur legale Märkte erhalten standardmäßig ein Blip auf der Karte.
- **Job-Rabatte:** Weise einem Job in der Konfiguration einen Rabatt beim Kauf von Kunstwerken zu.

## Wichtiger Hinweis zur Kompatibilität

Die Kernlogik des Skripts ist mit ESX und QBCore kompatibel.

**Die Benutzeroberfläche (Menüs) verwendet jedoch `ESX.UI`.** Das bedeutet, dass das Skript auf einem QBCore-Server zwar im Hintergrund funktioniert, die Menüs zum Kaufen und Verkaufen aber **nicht** angezeigt werden.

Für eine vollständige QBCore-Kompatibilität müsste die UI in `client/art_market.lua` auf eine QBCore-kompatible Bibliothek (z.B. `qb-menu` oder `ox_lib`) umgeschrieben werden.
