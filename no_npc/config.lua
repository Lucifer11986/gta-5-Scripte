Config = {
    ExemptNPCs = {
        "a_m_m_skater_01",
        "U_M_Y_Baygor",
        "CS_Tom",
        "S_M_M_Postal_01",
        "S_M_M_Postal_02",
        "a_m_y_business_01"
    }, -- Liste der NPCs, die nicht gelöscht werden sollen
    AllowedVehicles = {
        "dinghy2",
        "faggio"
    }, -- Liste der Fahrzeuge, die nicht entfernt werden sollen
    IgnorePlayerVehicles = true, -- Wenn true, werden Fahrzeuge, in denen Spieler sitzen, nicht entfernt
    IgnoreMissionEntities = true, -- Wenn true, werden Fahrzeuge oder NPCs, die als Missions-Entität markiert sind, nicht entfernt
    DebugMode = false, -- Setze auf true, um Debug-Nachrichten zu aktivieren. Hauptlogik wird davon nicht mehr beeinflusst.

    -- Fahrzeugschutz
    VehicleProtection = {
        ProtectPlayerOwned = true, -- Soll versucht werden, Spielerfahrzeuge zu schützen? (Erfordert ein Garagensystem, das den Export nutzt)
        ProtectAdminVehicles = true -- Soll versucht werden, von Admins gespawnte Fahrzeuge zu schützen?
    },

    -- Konfiguration für die Tierwelt
    SpawnWildlife = true, -- Sollen zusätzliche Wildtiere gespawnt werden?
    WildlifeModels = {
        "a_c_deer",
        "a_c_boar",
        "a_c_coyote",
        "a_c_mtlion"
    },
    WildlifeSpawnArea = { -- Bereich, in dem Wildtiere gespawnt werden (Standard: Paleto Forest)
        center = vector3(-450.0, 5500.0, 80.0),
        radius = 1500.0
    },
    WildlifeSpawnInterval = 60000, -- Intervall in Millisekunden (60 Sekunden)

    -- Performance-Einstellungen
    CleanupInterval = 10000, -- Intervall in Millisekunden für die Bereinigung von verbliebenen NPCs/Fahrzeugen (10 Sekunden)

    -- #############################################################################
    -- ## DENSITY SETTINGS (Zonen & Zeit)
    -- #############################################################################

    -- Standard-Dichte, wenn sich der Spieler in keiner der unten definierten Zonen befindet.
    DefaultDensity = {
        ped = 0.0,
        vehicle = 0.0
    },

    -- Zonen-basierte Dichte. Die erste Zone in der Liste, in der sich der Spieler befindet, wird verwendet.
    -- Dichtewerte sind Multiplikatoren: 1.0 = normal, 0.5 = 50%, 0.0 = aus.
    DensityZones = {
        {
            name = "Los Santos City",
            center = vector3(-150.0, -600.0, 160.0),
            radius = 3500.0,
            pedDensity = 0.3,
            vehicleDensity = 0.3
        },
        {
            name = "Sandy Shores & Grapeseed",
            center = vector3(1700.0, 3700.0, 40.0),
            radius = 1500.0,
            pedDensity = 0.1,
            vehicleDensity = 0.1
        },
        {
            name = "Paleto Bay",
            center = vector3(150.0, 6400.0, 30.0),
            radius = 1000.0,
            pedDensity = 0.2,
            vehicleDensity = 0.2
        }
    },

    -- Zeitgesteuerte Profile. Passt die Dichte basierend auf der realen Server-Uhrzeit an.
    -- Die Multiplikatoren werden auf die Zonen-Dichte angewendet.
    TimeProfiles = {
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
            endHour = 6, -- Beispiel für ein Profil, das über Mitternacht geht
            pedMultiplier = 0.5, -- 50% der Zonen-Dichte
            vehicleMultiplier = 0.5
        }
        -- In den Zeiten, die nicht abgedeckt sind, wird der Multiplikator 1.0 verwendet.
    }
}
