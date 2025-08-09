# 📜 FiveM Willkommensnachricht Script

Dieses Script zeigt eine personalisierte Willkommensnachricht an, sobald ein Spieler das Spiel betritt. Der Text wird aus der `config.lua` geladen und auf dem Bildschirm angezeigt.

---

## 🚀 Installation

1. **Herunterladen & Einfügen:**  
   Platziere das Script in deinem `resources`-Ordner von FiveM.

2. **Datei `config.lua` anpassen:**  
   Öffne die `config.lua` und passe die Willkommensnachricht an:

   ```lua
   Config = {}
   Config.WelcomeMessage = "Willkommen, %s! Viel Spaß auf unserem Server! 🚀"
   Config.MessageDuration = 10 -- Anzeigezeit in Sekunden

3. **Script in server.cfg starten:**
	Füge in deiner server.cfg folgende Zeile hinzu:
	
	ensure dein_scriptname

4. **Server Neustarten**

🛠 Funktionen
✅ Zeigt eine personalisierte Willkommensnachricht an
✅ Lädt den Text aus der config.lua
✅ Dynamische Anzeigezeit einstellbar
✅ Optimiert & performant

füge in deine datenbank 

ALTER TABLE users ADD COLUMN banned TINYINT(1) DEFAULT 0;

ein.