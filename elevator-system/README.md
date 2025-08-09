Advanced Elevator System for FiveM

Installation und Einrichtung

1. Dateien herunterladen

Stelle sicher, dass du alle notwendigen Dateien heruntergeladen hast:

client.lua

config.lua

fxmanifest.lua

2. Dateien in den Ressourcenordner einfügen

Lege einen neuen Ordner namens elevator-system im Verzeichnis deines FiveM-Servers an: resources/[scripts]/elevator-system.

Kopiere die Dateien client.lua, config.lua und fxmanifest.lua in diesen Ordner.

3. Resource in server.cfg registrieren

Öffne die server.cfg deines FiveM-Servers und füge folgende Zeile hinzu:

ensure elevator-system

4. Konfiguration anpassen

Öffne die Datei config.lua, um die Stockwerksdaten, Koordinaten und Anforderungen (z. B. Job oder Rang) zu ändern.

Beispiel für ein neues Stockwerk:

{x = -1050.0, y = -850.0, z = 5.0, label = 'Dachterrasse'}

Funktionsweise

Das Skript erlaubt es Spielern, zwischen verschiedenen Stockwerken zu wechseln.

Sicherheitsprüfungen stellen sicher, dass die Zielorte zugänglich sind.

Eine Animation wird während der Fahrstuhlfahrt abgespielt, um die Immersion zu erhöhen.

Rechtliche Aspekte

Dieses Skript wurde von Lucifer | Awaria Modding entwickelt.

Es darf nur für private Server verwendet werden. Weitergabe oder Verkauf ist untersagt.

Änderungen am Skript sind erlaubt, solange der ursprüngliche Autor genannt wird.

Support

Bei Problemen oder Fragen öffne ein Ticket auf unserem Discord-Server: Awaria Modding Discord

Wir helfen dir gerne bei der Einrichtung oder Anpassung!