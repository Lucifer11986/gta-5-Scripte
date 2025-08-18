# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [4.0.0] - 2025-08-10
### Added
- **Schneeketten-System:**
    - Hinzufügen des `snow_chains` Items.
    - Logik zum Anbringen und Entfernen von Schneeketten an Fahrzeugen.
    - Schneeketten verbessern den Grip auf vereisten Straßen im Winter.
    - Schneeketten haben eine begrenzte Haltbarkeit.
    - Das Nutzen von Schneeketten außerhalb des Winters zerstört die Reifen.

## [3.0.0] - 2025-08-10
### Added
- **Winter-Survival-Mechanik:**
    - Spieler erleiden Kälteschaden, wenn sie nicht warm genug gekleidet sind.
    - Schutz vor Kälte in geschlossenen Fahrzeugen und Innenräumen.
    - Visueller "Frier-Effekt".
- **Umwelt-Effekte:**
    - Fallende Laub-Partikel im Herbst.
    - Reduzierter Fahrzeug-Grip bei Minusgraden im Winter zur Simulation von Glatteis.
- **Dynamische Wetter-Events:**
    - Zufällige Stromausfälle bei Gewitter.
    - Zufällige Buschfeuer bei Hitzewellen.
    - Zufällige "Straßensperrungen" (via Map-Blips) bei Schneestürmen.
- **Debug-Befehl:** `/myclothes`-Befehl zur Anzeige von Kleidungs-IDs.

### Changed
- Das Client-Server-Kommunikationsmodell für das Survival-System wurde von Callbacks auf Events umgestellt, um die Kompatibilität mit verschiedenen ESX-Versionen zu gewährleisten.
- Die Server-Logik wurde angepasst, um mit nicht-standardmäßigen `esx_status`-Konfigurationen umzugehen und Abstürze zu verhindern.

## [2.0.0] - 2025-08-09
### Added
- **Saisonale Sammel-Events:**
    - Herbst-Event (Kürbissuche) mit Seltenheits-Belohnungssystem und begrenzter Dauer.
    - Winter-Event (Geschenkesuche) mit Seltenheits-Belohnungssystem und begrenzter Dauer.
- **Dynamische Temperatur:** Die Temperatur ändert sich nun in regelmäßigen Abständen innerhalb einer Jahreszeit.
- **Jahreszeiten-Benachrichtigung:** Eine große Benachrichtigung wird angezeigt, wenn sich die Jahreszeit ändert.

### Fixed
- **Oster-Event Logik:**
    - Das Event startet nun nur noch im Frühling.
    - Die Zufälligkeit der Eier-Positionen wurde durch einen korrekten Algorithmus und Seeding verbessert.
    - Die Belohnungs-Benachrichtigung zeigt nun den korrekten Item-Namen an.
- **Race Condition beim Start:** Die Initialisierungslogik wurde überarbeitet, um sicherzustellen, dass alle Skript-Teile von derselben korrekten Jahreszeit ausgehen.
- Diverse "not safe for net" und "nil value" Fehler wurden behoben.

### Changed
- **Code-Struktur:**
    - Veraltete und widersprüchliche Skripte (`season_events.lua`, `weather.lua`) wurden deaktiviert oder entfernt.
    - Die Logik wurde in neue, dedizierte Skripte (`survival_effects.lua`, `dynamic_events.lua` etc.) aufgeteilt.
    - Das manuelle Laden der `config.lua` wurde entfernt.
    - Das Haupt-Wetterskript (`weather_seasons.lua`) wurde zur alleinigen Quelle für Jahreszeiten und Wetter gemacht und nutzt nun korrekt die `config.lua`.

## [1.0.0] - Initial Version
- Ursprüngliche Version von Lucifer | Awaria Modding.
=======
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [4.0.0] - 2025-08-10
### Added
    - Schneeketten-System:

    - Einführung des Items snow_chains zur Verwendung im Spiel.

    - Möglichkeit, Schneeketten an Fahrzeugen verschiedener Klassen anzubringen, je nach Fahrzeugtyp unterschiedliche Menge erforderlich.

    - Schneeketten verbessern den Grip auf vereisten Straßen speziell in der Wintersaison.

    - Haltbarkeit der Schneeketten ist zeitlich begrenzt (standardmäßig 30 Minuten Spielzeit).

    - Schneeketten verursachen Schaden an Reifen, wenn sie außerhalb der Wintersaison verwendet werden.

    - Schneeketten können jederzeit vom Spieler entfernt werden, sind danach verbraucht und können nicht wiederverwendet werden.

    - Server- und Client-seitige Animationen und Benachrichtigungen beim Anbringen und Entfernen von Schneeketten.

    - Automatischer Reifen-Schaden bei falscher Jahreszeit, verhindert missbräuchliche Nutzung.

Changed
    - Verbesserung der Server-Client-Kommunikation bzgl. Schneeketten.

    - Optimierung der Fahrzeugerkennung und Entfernungskontrolle mit Abstands-Check.

    - Fehlerbehebung bei Reifenzerstörung in Nicht-Winter-Jahreszeiten.
## [3.0.0] - 2025-08-10
### Added
- **Winter-Survival-Mechanik:**
    - Spieler erleiden Kälteschaden, wenn sie nicht warm genug gekleidet sind.
    - Schutz vor Kälte in geschlossenen Fahrzeugen und Innenräumen.
    - Visueller "Frier-Effekt".
- **Umwelt-Effekte:**
    - Fallende Laub-Partikel im Herbst.
    - Reduzierter Fahrzeug-Grip bei Minusgraden im Winter zur Simulation von Glatteis.
- **Dynamische Wetter-Events:**
    - Zufällige Stromausfälle bei Gewitter.
    - Zufällige Buschfeuer bei Hitzewellen.
    - Zufällige "Straßensperrungen" (via Map-Blips) bei Schneestürmen.
- **Debug-Befehl:** `/myclothes`-Befehl zur Anzeige von Kleidungs-IDs.

### Changed
- Das Client-Server-Kommunikationsmodell für das Survival-System wurde von Callbacks auf Events umgestellt, um die Kompatibilität mit verschiedenen ESX-Versionen zu gewährleisten.
- Die Server-Logik wurde angepasst, um mit nicht-standardmäßigen `esx_status`-Konfigurationen umzugehen und Abstürze zu verhindern.

## [2.0.0] - 2025-08-09
### Added
- **Saisonale Sammel-Events:**
    - Herbst-Event (Kürbissuche) mit Seltenheits-Belohnungssystem und begrenzter Dauer.
    - Winter-Event (Geschenkesuche) mit Seltenheits-Belohnungssystem und begrenzter Dauer.
- **Dynamische Temperatur:** Die Temperatur ändert sich nun in regelmäßigen Abständen innerhalb einer Jahreszeit.
- **Jahreszeiten-Benachrichtigung:** Eine große Benachrichtigung wird angezeigt, wenn sich die Jahreszeit ändert.

### Fixed
- **Oster-Event Logik:**
    - Das Event startet nun nur noch im Frühling.
    - Die Zufälligkeit der Eier-Positionen wurde durch einen korrekten Algorithmus und Seeding verbessert.
    - Die Belohnungs-Benachrichtigung zeigt nun den korrekten Item-Namen an.
- **Race Condition beim Start:** Die Initialisierungslogik wurde überarbeitet, um sicherzustellen, dass alle Skript-Teile von derselben korrekten Jahreszeit ausgehen.
- Diverse "not safe for net" und "nil value" Fehler wurden behoben.

### Changed
- **Code-Struktur:**
    - Veraltete und widersprüchliche Skripte (`season_events.lua`, `weather.lua`) wurden deaktiviert oder entfernt.
    - Die Logik wurde in neue, dedizierte Skripte (`survival_effects.lua`, `dynamic_events.lua` etc.) aufgeteilt.
    - Das manuelle Laden der `config.lua` wurde entfernt.
    - Das Haupt-Wetterskript (`weather_seasons.lua`) wurde zur alleinigen Quelle für Jahreszeiten und Wetter gemacht und nutzt nun korrekt die `config.lua`.

## [1.0.0] - Initial Version
- Ursprüngliche Version von AbyssForge Studio.

