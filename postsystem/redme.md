# 📮 Post & Paket System für FiveM

Ein umfassendes Script für FiveM, das ein interaktives Post- und Paketsystem zu deinem Server hinzufügt. Spieler können Briefe und Pakete versenden, einen Job als Postbote annehmen, eigene Briefkästen aufstellen und vieles mehr.

---

## 🌟 Features

- **Briefe & Pakete:** Sende Briefe oder Gegenstände an andere Spieler.
- **Postboten-Job:** Ein vollwertiger Job mit einem Schichtsystem (Einstempeln/Ausstempeln).
- **GPS-geführte Lieferrouten:** Postboten erhalten dynamische Routen zu den Briefkästen der Empfänger.
- **Persistente Briefkästen:** Spieler können eigene Briefkästen kaufen und in der Welt platzieren.
- **Polizei-Inspektion:** Polizisten können an Poststationen Pakete auf illegale Inhalte überprüfen und diese beschlagnahmen.
- **Express-Versand:** Optionen für schnellere Lieferungen.
- **Datenbank-Speicherung:** Alle Nachrichten, Pakete und Briefkästen werden persistent in der Datenbank gespeichert.

---

## 🛠️ Installation

### ✅ Voraussetzungen

- **ESX** (getestet mit ESX Legacy)
- **oxmysql** (für die Datenbankverbindung)
- **esx_skin** & **skinchanger** (für das An- und Ausziehen der Uniform)

### 📂 Schritte

1.  **Script herunterladen** und im `resources`-Ordner platzieren.
2.  **Datenbank einrichten**: Die `sql.sql` und `postsystem_update.sql` werden beim Start des Scripts automatisch ausgeführt. Sie erstellen alle notwendigen Tabellen und fügen die neuen Items (`stamp`, `cardboard_box`, `mailbox_item`) hinzu.
3.  **Items zu Shops hinzufügen**: Füge die neuen Items (`cardboard_box`, `mailbox_item`, `stamp`) zu deinen Shops hinzu, damit Spieler sie kaufen können. Beispiel:
    ```sql
    INSERT INTO `shops` (`store`, `item`, `price`) VALUES
      ('LTDgasoline', 'stamp', 50),
      ('LTDgasoline', 'cardboard_box', 100),
      ('RobsLiquor', 'mailbox_item', 500);
    ```
4.  **Script starten**: Füge `ensure postsystem` in deine `server.cfg` ein.
5.  **Konfiguration anpassen**: Bearbeite die `config.lua`, um das Script an deine Bedürfnisse anzupassen (z.B. Job-Einstellungen, Positionen, etc.).

---

## 🎮 Spieler-Anleitung

### Briefe & Pakete versenden
1.  Gehe zu einer Poststation (siehe Karte).
2.  Drücke `[E]`, um das Menü zu öffnen.
3.  **Briefe:** Wähle den "Brief Senden"-Tab, fülle die Felder aus und klicke auf "Versenden". Du benötigst eine `Briefmarke`.
4.  **Pakete:** Wähle den "Paket Senden"-Tab. Du benötigst einen `Karton`. Wähle einen Gegenstand aus deinem Inventar und einen Empfänger.

### Eigenen Briefkasten aufstellen
1.  Kaufe einen `Briefkasten` im Shop.
2.  Benutze das Item aus deinem Inventar.
3.  Bewege den Briefkasten an die gewünschte Position.
4.  Benutze die `LINKS`/`RECHTS`-Pfeiltasten zum Drehen.
5.  Drücke `[E]`, um den Briefkasten zu platzieren, oder `[G]` zum Abbrechen.

### Postbote werden (Schichtsystem)
1.  Gehe zum Job-Center für Postboten (siehe `config.lua`).
2.  Drücke `[E]`, um deine Schicht zu beginnen. Deine Kleidung wird automatisch zur Uniform gewechselt.
3.  Gehe zu einer Poststation und drücke `[E]`, um das Menü zu öffnen.
4.  Klicke auf `Lieferroute starten`. Du erhältst eine GPS-Route zur ersten Adresse.
5.  Fahre zum markierten Briefkasten und drücke `[E]`, um das Paket zuzustellen. Du erhältst automatisch das nächste Ziel.
6.  Um deine Schicht zu beenden, gehe zurück zum Job-Center und drücke erneut `[E]`.

### Polizei-Inspektion
1.  Gehe als Polizist (`job = 'police'`) zu einer Poststation.
2.  Öffne das Menü mit `[E]`.
3.  Wähle den "Polizei"-Tab.
4.  Hier siehst du eine Liste aller wartenden Pakete.
5.  Klicke auf `Beschlagnahmen`, um ein Paket zu entfernen und den Inhalt in dein Inventar zu legen.
