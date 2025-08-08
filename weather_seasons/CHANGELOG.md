
📝 **CHANGELOG**

## **v1.3 - (18. Februar 2025)**

### 📌 **Neuerungen & Verbesserungen:**
✅ **Sanfte Übergänge für Jahreszeiten & Wetter**
- Wetter ändert sich jetzt **weicher über 10–15 Sekunden** statt abrupt zu wechseln.
- **SetWeatherTypeTransition** optimiert für einen realistischen Übergang.
- Temperatur steigt oder fällt nun **in kleinen Schritten** für mehr Immersion.
- **Timecycle Modifier** werden langsam verstärkt/abgeschwächt, um harte Sprünge zu vermeiden.

✅ **Verbesserung der Schnee- & Hitzewellen-Effekte**
- Winter hat jetzt einen **dynamischen Schneefall**, der sich sanft verändert.
- Hitzewellen-Effekt geht **fließend in normalen Sommer über** (kein harter Wechsel).
- **Neue visuelle Effekte** für extreme Wetterlagen mit sanften Übergängen.

✅ **Optimierte Wetter- & Temperatur-Kontrolle**
- **Neue Funktion:** Automatische Temperatur- und Wetterüberprüfung alle 60 Sekunden.
- Bei Hitzewellen oder Schnee wird das Wetter **schrittweise** angepasst.

✅ **Verbesserte Benachrichtigung für Jahreszeitenwechsel**
- Neuer **automatischer Hinweis**, wenn eine neue Jahreszeit beginnt.
- Sanfte **Blenden & Fadings** für immersivere Wechsel.
- Textfarbe und Formatierung optimiert für bessere Lesbarkeit.

---

## **v1.2 - (15. Februar 2025)**

📌 **Neuerungen & Verbesserungen:**
✅ **Kirschblüten-Festival hinzugefügt!** 🌸
- Admin-Befehl: `/startBlossomFestival` startet das Event.
- Admin-Befehl: `/stopBlossomFestival` beendet das Event.
- Automatische Aktivierung der Kirschblüten-Bäume, solange das Event aktiv ist.
- Blütenregen-Effekte an speziellen Orten während des Festivals.
- Festival-Markt mit zufälligen Belohnungen für Spieler.

✅ **Optimierungen & Fixes:**
- Kirschblüten-Resource wird nur während des Events geladen und danach entfernt.
- Fehlermeldung, falls die Resource "cherryblossom" nicht vorhanden ist.
- Verbesserte Admin-Prüfung für Befehle.

---

## **v1.1 - (13. Februar 2025)**

📌 **Neuerungen & Verbesserungen:**
✅ **Zufällige Wetterereignisse:**
- Frühling hat jetzt eine **30% Chance auf Regen** (max. 10 Minuten).
- Herbst hat jetzt eine **30% Chance auf Sturm** (max. 10 Minuten).

✅ **Alle Konfigurationswerte in die `config.lua` verschoben.**
✅ **Intervall für Wetteränderungen nun einstellbar** (Standard: 5 Minuten).
✅ **Optionale Zeiten für Wetterzyklen (2 Wochen bis 6 Monate) als Kommentare hinzugefügt.**

---

## **v1.0 - (12. Februar 2025)**

🌍 **Einführung des dynamischen Wetter- und Jahreszeiten-Systems**

- **Frühling:** Blühende Pflanzen, mildes Wetter.
- **Sommer:** Sonnig & heiß.
- **Herbst:** Blätterfall, kühles Wetter.
- **Winter:** Schnee & Kälte.
- 🌦 **Wetter synchronisiert sich automatisch mit allen Spielern.**
- ⏳ **Jahreszeiten wechseln automatisch alle X Minuten (einstellbar in `config.lua`).**
- ❄️ **Winter hat Schnee auf Straßen & Fußspuren werden sichtbar.**
- 🌿 **Partikeleffekte passend zur Jahreszeit (Blüten, Sonne, Blätter, Schnee).**
