# Spieler-Bonitätssystem für ESX Legacy RP-Server

## **Einleitung**
Dieses Script führt ein fortschrittliches Bonitätssystem ein, das speziell für ESX Legacy-basierte FiveM-Roleplay-Server entwickelt wurde. Es ermöglicht Spielern, ihre Kreditwürdigkeit zu verwalten, Kredite aufzunehmen und ihre Finanzen zu verbessern, während Banker tiefere Einblicke in die Finanzdaten der Spieler erhalten können. 

---

## **Funktionen**

### **Kernfunktionen:**
- **Bonitätsmanagement:**
  Spieler haben individuelle Bonitätswerte, die sich dynamisch basierend auf ihrem finanziellen Verhalten ändern (z. B. Immobilienbesitz, verfügbares Bargeld, Kreditstatus).

- **Banker-Befehle:**
  Banker können detaillierte Berichte über die Kreditdaten von Spielern abrufen, einschließlich:
  - Bonitätswert.
  - Maximale Kreditlimits.
  - Ausstehende Kredite.
  - Verpasste Zahlungen.

- **Spieler-Befehle:**
  Spieler können ihre eigene Bonität und Kreditdetails überprüfen.

### **Premium-Funktionen:**
- **Kreditzinsen basierend auf Bonität:**
  Spieler mit hoher Bonität erhalten günstigere Zinsen.

- **Kreditlimits:**
  Das maximale Kreditlimit basiert auf dem Bonitätswert und den Vermögenswerten des Spielers.

- **Immobilien- und Fahrzeugpfändung:**
  Bei wiederholtem Kreditausfall können Immobilien oder Fahrzeuge gepfändet werden.

- **Wirtschaftliches Ranking:**
  Spieler können ihre wirtschaftliche Position im Vergleich zu anderen Spielern einsehen.

- **Integration von Versicherungen:**
  Spieler können Versicherungen abschließen, die bei Zahlungsausfällen helfen.

### **Zusätzliche Verbesserungen:**
- **Dynamische Score-Anpassungen:**
  Die Bonität ändert sich basierend auf:
  - Verfügbarem Bargeld.
  - Anzahl der besessenen Immobilien.
  - Kreditstatus und verpassten Zahlungen.

- **Integration mit anderen Scripts:**
  Das Script ist so gestaltet, dass es einfach mit anderen Scripts, wie z. B. Fahrzeug- oder Immobilienmanagement, verbunden werden kann. Details hierzu finden Sie im Abschnitt "Integration".

- **Escrow-Schutz:**
  Gewährleistet eine sichere Bereitstellung und Integrität des Scripts.

---

## **Installationsanleitung**

1. **Abhängigkeiten:**
   - ESX Legacy
   - oxmysql

2. **Setup:**
   - Fügen Sie die Script-Dateien in Ihren Ressourcenordner ein.
   - Importieren Sie die bereitgestellte SQL-Datei in Ihre Datenbank.

3. **Konfiguration:**
   - Öffnen Sie `config.lua`, um Premium-Rollen, Warnschwellen und andere Einstellungen anzupassen.

4. **Ressourcenaktivierung:**
   - Fügen Sie `ensure boni_pruefung` zu Ihrer `server.cfg` hinzu.

---

## **Befehle**

### **Für Spieler:**
- `/checkcredit`:
  Zeigt die Bonität, ausstehende Kredite und verpasste Zahlungen des Spielers an.

- `/applyloan [Betrag]`:
  Beantrage einen Kredit in Höhe von [Betrag]. Der Spieler wird über Zinsen und Rückzahlungsbeträge informiert.

- `/repayloan [Betrag]`:
  Bezahle einen Teil oder den gesamten ausstehenden Kredit zurück.

### **Für Banker:**
- `/checkcreditplayer [PlayerID]`:
  Zeigt einen detaillierten Bericht über den finanziellen Status eines Spielers an, einschließlich:
  - Bonitätswert.
  - Maximale Kreditlimits.
  - Offene Kredite.
  - Verpasste Zahlungen.

- `/assignloan [PlayerID] [Betrag] [Zinssatz]`:
  Gewähre einem Spieler einen Kredit mit einem bestimmten Betrag und Zinssatz.

### **Weitere Befehle:**
- `/setinsurance [PlayerID] [Versicherungstyp]`:
  Weist einem Spieler eine Versicherung zu.

- `/rankings`:
  Zeigt das wirtschaftliche Ranking der Spieler basierend auf ihrem Vermögen und Bonitätswert an.

---

## **SQL-Schema**
- **Tabelle:** `users`
  - Neue Spalten:
    - `credit_score` (INT, Standard: 500)
    - `outstanding_loans` (INT, Standard: 0)
    - `missed_payments` (INT, Standard: 0)
    - `insurance` (VARCHAR, Standard: 'Keine')

---

## **Integration mit anderen Scripts**

Das Script ist modular aufgebaut und kann einfach mit anderen Scripts integriert werden. Hier einige Beispiele:

1. **Fahrzeugfinanzierung:**
   - Nutzen Sie die Bonitätsdaten, um Fahrzeugkäufe auf Raten anzubieten. Spieler mit niedriger Bonität zahlen höhere Raten.

2. **Immobilienmanagement:**
   - Verknüpfen Sie das Bonitätssystem mit Immobilienkäufen, sodass Spieler mit besserer Bonität Zugang zu besseren Immobilien erhalten.

3. **Job-Systeme:**
   - Passen Sie die Jobmöglichkeiten basierend auf der Bonität an, z. B. höhere Anforderungen für prestigeträchtige Jobs.

4. **Versicherungssystem:**
   - Integrieren Sie Versicherungs-Scripts, die bei Kreditausfällen greifen und Zahlungen absichern.

---

## **Tebex Store Beschreibung**

### **Titel:**
Spieler-Bonitätssystem für FiveM RP-Server (ESX Legacy)

### **Beschreibung:**
Erweitern Sie Ihren FiveM-Roleplay-Server mit unserem fortschrittlichen Bonitätssystem, das speziell für ESX Legacy entwickelt wurde. Perfekt für immersives finanzielles Rollenspiel, bietet dieses Script:

- **Dynamisches Bonitätsmanagement:** Die Bonität der Spieler passt sich ihrem finanziellen Verhalten an.
- **Integration der Banker-Rolle:** Banker erhalten Zugriff auf detaillierte Bonitätsberichte für Rollenspiel-Szenarien.
- **Premium-Unterstützung:** Belohnen Sie VIP-Spieler mit täglichen Boni.
- **Kreditmanagementsystem:** Beinhaltet automatische Warnungen und Strafen für überfällige Zahlungen.
- **Kreditzinsen und Pfändung:** Erhöhen Sie den Realismus durch anpassbare Zinsen und Pfändung bei Kreditausfällen.

### **Funktionen:**
- Echtzeit-Score-Updates.
- Anpassbare Schwellenwerte und Boni.
- Wirtschaftliches Ranking und Versicherungssystem.
- Escrow-geschützt für sichere Bereitstellung.

**Kompatibel mit:** ESX Legacy, oxmysql

**Bereichern Sie die Ökonomie und Spielerinteraktionen Ihres Servers noch heute!**

