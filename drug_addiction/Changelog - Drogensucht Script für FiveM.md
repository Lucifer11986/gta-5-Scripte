Changelog - Drogensucht Script für FiveM
Version 1.0 - Initial Release
Neue Features:
Drogensucht-System:

Integration eines Drogensucht-Systems, das den Konsum und die Auswirkungen von Drogen simuliert.
System zur Anpassung des Suchtlevels jedes Spielers.
Speicherung des Suchtlevels und der Drogenhistorie in einer SQL-Datenbank.
Drogenkonsum-Effekte:

Implementierung von visuellen und physischen Effekten (z.B. Bildschirmverzerrungen, Wackelkamera, Geschwindigkeitseffekte) bei Drogeneinnahme.
Jede Droge hat spezifische Auswirkungen (z.B. LSD, Cocaine, Meth).
Effekte sind für zufällige Zeitspannen (10-15 Sekunden) aktiv und werden anschließend automatisch deaktiviert.
Entzugserscheinungen:

Spieler erfahren Entzugserscheinungen bei zu langem Drogenentzug.
Symptome wie verschwommenes Sehen, Wackelkamera, langsameres Bewegen und HP-Verlust werden angezeigt.
Therapie-Mechanismus:

Spieler können eine Therapie bei einem Arzt starten, um ihre Sucht zu heilen.
Kosten und Wartezeiten für die Therapie sind konfigurierbar.
Suchtlevel wird nach erfolgreicher Therapie auf null zurückgesetzt.
Transaktionen und Speicherung:

Ein Transaktionssystem für Drogenkäufe und Therapiezahlungen wurde eingeführt.
Transaktionen werden in der Datenbank gespeichert, um alle finanziellen Vorgänge nachzuverfolgen.
Neue Datenbanktabellen:

transactions: Speicherung aller Drogenkäufe und Therapie-Zahlungen.
addiction_data: Speicherung des Suchtlevels und der letzten Konsumdaten der Spieler.
drug_effects: Speicherung der Drogeneffekte und deren Parameter.
drugs: Speicherung von Drogendaten wie Name, Preis, Effekte und Suchtpotenzial.
rehab_sessions: Speicherung von Therapie-Informationen (Kosten, Beginn und Ende der Therapie).
Strukturänderungen:
Ordnerstruktur:

Alle relevanten Skripte wurden in separate Dateien und Ordner strukturiert, basierend auf der zuletzt aktualisierten Struktur.
Strukturierung der client, server, und shared Ordner für bessere Übersichtlichkeit und Modularität.
Client-Skripte:

Erstellung von client/effects.lua für die Verwaltung von Drogeneffekten (visuelle Effekte, Bewegungseffekte).
Erstellung von client/drug_use.lua zur Handhabung des Drogensystems (Konsum, Suchtlevel).
Server-Skripte:

Erstellung von server/main.lua zur Verwaltung der Drogensucht und zur Implementierung der Serverlogik (z. B. Setzen des Suchtlevels, Behandlung von Transaktionen).
Erstellung von server/transactions.lua zur Speicherung und Verarbeitung von Transaktionsdaten (Drogenkäufe und Therapiekosten).
Datenbank:

Erstellung der SQL-Datenbanken, die mit den oben genannten Skripten kompatibel sind.
Tabellen wurden erstellt, um Transaktionen, Suchtlevel und Drogeneffekte zu speichern.
Bugfixes & Optimierungen:
Stabilität:
Code-Optimierungen und Fehlerbehebungen, um die Zuverlässigkeit des Drogensucht-Systems sicherzustellen.
Beseitigung von potentiellen Speicherlecks bei wiederholtem Drogenkonsum.
Performance:
Minimierung der Serverlast durch effiziente Datenbankabfragen und Ereignis-Trigger für den Drogenkonsum.
Benutzerfreundlichkeit:
Klare Rückmeldungen an den Spieler bei der Durchführung von Transaktionen (z. B. Notifikationen bei unzureichendem Geld).
Detaillierte Fehlermeldungen, wenn erforderliche Daten (wie Suchtlevel oder Drogeninformationen) fehlen.
Weitere Änderungen:
Konfigurationsdatei (Config.lua):
Anpassbare Konfigurationen für Preise, Therapiezeiten, Drogenarten und deren Effekte.
Erlaubt einfache Anpassungen der Drogensystemwerte durch den Serveradministrator.
Reha-System:
Möglichkeit, das Reha-System für die Spiel-Community anzupassen, einschließlich der Kosten und Zeitspannen.