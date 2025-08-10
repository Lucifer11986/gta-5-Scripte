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
    DebugMode = false, -- Setze auf true, um Debug-Nachrichten zu aktivieren. Hauptlogik wird davon nicht mehr beeinflusst.

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
    CleanupInterval = 10000 -- Intervall in Millisekunden für die Bereinigung von verbliebenen NPCs/Fahrzeugen (10 Sekunden)
}
