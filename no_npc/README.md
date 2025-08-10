# no_npc - Advanced NPC & Vehicle Manager

## Beschreibung

**no_npc** ist ein hochgradig performantes und konfigurierbares Skript für FiveM, um die Population von NPCs und Fahrzeugen auf einem Server dynamisch zu steuern. Es wurde von Grund auf neu geschrieben, um maximale Leistung und Flexibilität zu bieten. Es ist ideal für Server, die eine präzise Kontrolle über die Spielwelt-Atmosphäre benötigen, von komplett leeren Straßen bis hin zu belebten Zonen, die sich je nach Tageszeit ändern.

## Features

- **Hohe Performance:** Keine teuren Schleifen in `Wait(0)`. Die Logik ist in performante Threads aufgeteilt.
- **Zonen-basierte Dichte:** Definieren Sie verschiedene Zonen (z.B. Stadt, Land) mit individuellen Dichte-Einstellungen für NPCs und Fahrzeuge.
- **Zeitgesteuerte Profile:** Passen Sie die Dichte automatisch an die reale Server-Uhrzeit an (z.B. weniger Verkehr in der Nacht).
- **Fahrzeugschutz-System:** Schützen Sie Spieler- und Admin-Fahrzeuge vor dem Entfernen durch ein robustes Export-System.
- **Admin-Befehle:** Vollständige In-Game-Kontrolle über die Kernfunktionen.
- **Konfigurierbare Safe-Zones:** Erstellen Sie per Befehl absolute Schutzzonen, in denen nichts entfernt wird.
- **Whitelist/Blacklist:** Detaillierte Konfiguration, welche NPCs und Fahrzeuge von den Regeln ausgenommen sind.
- **Dynamisches Wildtier-System:** Spawnen Sie zusätzliche Wildtiere in konfigurierbaren Gebieten.

## Installation

1.  Laden Sie den Ordner `no_npc` herunter.
2.  Platzieren Sie ihn in Ihrem `resources`-Verzeichnis.
3.  Fügen Sie `ensure no_npc` zu Ihrer `server.cfg` hinzu.

## Konfiguration (`config.lua`)

Die `config.lua` ist das Herzstück des Skripts. Hier können Sie fast jedes Detail anpassen.

---

### Allgemeine Einstellungen

```lua
Config = {
    ExemptNPCs = { "a_m_m_skater_01", ... }, -- NPCs, die nie entfernt werden.
    AllowedVehicles = { "dinghy2", ... },   -- Fahrzeuge, die nie entfernt werden.
    IgnorePlayerVehicles = true,            -- Fahrzeuge mit Spielern an Bord ignorieren.
    IgnoreMissionEntities = true,           -- Entitäten, die als "Missions-Entität" markiert sind, ignorieren.
    DebugMode = false,                      -- Aktiviert Debug-Nachrichten in der Konsole.
    -- ...
}
```

---

### Fahrzeugschutz

```lua
Config.VehicleProtection = {
    ProtectPlayerOwned = true, -- Wenn true, wird das Export-System aktiviert.
    ProtectAdminVehicles = true -- Platzhalter für zukünftige Features.
}
```
Damit andere Skripte (z.B. Garagen-Systeme) Fahrzeuge schützen können, müssen sie die Exports dieses Skripts verwenden. Siehe Abschnitt "Für Entwickler".

---

### Dichte-Einstellungen

Dies ist das mächtigste Feature. Sie können Zonen und Zeitprofile kombinieren.

```lua
-- Standard-Dichte, wenn man in keiner Zone ist.
Config.DefaultDensity = {
    ped = 0.0,
    vehicle = 0.0
}

-- Zonen mit eigener Dichte (1.0 = 100%, 0.0 = 0%)
Config.DensityZones = {
    {
        name = "Los Santos City",
        center = vector3(-150.0, -600.0, 160.0),
        radius = 3500.0,
        pedDensity = 0.3,
        vehicleDensity = 0.3
    },
    -- ... weitere Zonen
}

-- Zeitprofile, die die Dichte multiplizieren
Config.TimeProfiles = {
    {
        name = "Peak Hours (4 PM - 10 PM)",
        startHour = 16,
        endHour = 22,
        pedMultiplier = 1.0, -- 100% der Zonen-Dichte
        vehicleMultiplier = 1.0
    },
    {
        name = "Off-Peak (11 PM - 6 AM)",
        startHour = 23,
        endHour = 6, -- Geht über Mitternacht
        pedMultiplier = 0.5, -- 50% der Zonen-Dichte
        vehicleMultiplier = 0.5
    }
}
```
**Wichtig:** `DensityZones` steuern, **wie viele** NPCs es gibt. Wenn Sie einen Bereich **komplett schützen** wollen, benutzen Sie den Admin-Befehl `/setSafeZone`.

---

### Weitere Einstellungen

- **`SpawnWildlife`:** Konfigurieren Sie, ob und wo zusätzliche Wildtiere spawnen sollen.
- **`CleanupInterval`:** Legt fest, wie oft (in Millisekunden) die "Aufräum-Schleife" läuft, die verbliebene NPCs/Fahrzeuge entfernt.

## Admin-Befehle

Für die Nutzung der Befehle sind ACE-Permissions erforderlich.

| Befehl                 | Parameter        | Beschreibung                                       | Benötigte Permission |
| ---------------------- | ---------------- | -------------------------------------------------- | -------------------- |
| `/toggleSpawning`      | -                | Schaltet das NPC- und Fahrzeug-Spawning global an/aus. | `admin.spawning`     |
| `/setSafeZone`         | `[radius]`       | Erstellt eine Schutzzone an der aktuellen Position.  | `admin.safezone`     |
| `/clearSafeZones`      | -                | Löscht alle erstellten Schutzzonen.                | `admin.safezone`     |
| `/getSafeZones`        | -                | Listet alle aktiven Schutzzonen im Chat auf.       | `admin.safezone`     |

### ACE-Permissions Beispiel

Fügen Sie dies zu Ihrer `server.cfg` oder einer anderen Permissions-Datei hinzu:
```
add_ace group.admin admin.spawning allow
add_ace group.admin admin.safezone allow
```

## Für Entwickler (Exports)

Sie können Ihre Skripte mit `no_npc` interagieren lassen, um Fahrzeuge zu schützen.

**`exports.no_npc:protectVehicle(netId)`**
Markiert ein Fahrzeug als geschützt. Sie müssen die Netzwerk-ID des Fahrzeugs übergeben.

*Beispiel in einem Garagen-Skript:*
```lua
local vehicle = CreateVehicle(...)
-- Warten, bis das Fahrzeug eine Netzwerk-ID hat
while not NetworkGetEntityIsNetworked(vehicle) do
    Citizen.Wait(100)
end
local netId = VehToNet(vehicle)
exports.no_npc:protectVehicle(netId)
```

**`exports.no_npc:unprotectVehicle(netId)`**
Hebt den Schutz eines Fahrzeugs wieder auf.

## Credits

- **Original-Autor:** Lucifer | Awaria Modding
- **Komplettes Refactoring & neue Features:** Jules
