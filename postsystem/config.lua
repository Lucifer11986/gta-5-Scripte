Config = {}

-- Debug-Modus
Config.Debug = true

-- Poststationen
Config.PostStations = {
    {x = -422.7484, y = 6136.3213, z = 30.8773, heading = 229.2832, name = "Paleto Post Office"},
    {x = 1704.1533, y = 3779.5806, z = 33.7553, heading = 208.1156, name = "Sandy Post Office"},  
    {x = 380.5149, y = -833.3210, z = 28.2917, heading = 176.3530, name = "City Post Office"}
}

-- Blip-Einstellungen
Config.BlipSettings = {
    sprite = 280,
    color = 2,
    scale = 0.8
}

-- Benachrichtigungsdauer
Config.NotificationDuration = 5000

-- Versandgebühren
Config.DeliveryFee = 100 -- Standardgebühr für den Versand
Config.ExpressMultiplier = 3 -- Expressversand kostet das Doppelte
Config.ExpressDeliveryTime = 5 -- Zeit in Sekunden, bis die Express-Mail ankommt
Config.StandardDeliveryTime = 120 -- Zeit in Sekunden, bis die Standard-Mail ankommt

-- Briefmarken-System
Config.StampPrice = 50 -- Preis für eine Briefmarke
Config.StampItem = "stamp" -- Item-Name für die Briefmarke (muss in der Datenbank existieren)

-- Postfach-Kapazität
Config.MailboxCapacity = 20 -- Maximale Anzahl von Nachrichten, die ein Spieler speichern kann

-- Fraktionen/Gruppen
Config.Factions = {
    { name = "police", ranks = { "recruit", "officer", "chief" } },
    { name = "ambulance", ranks = { "paramedic", "doctor", "chief" } },
    { name = "mechanic", ranks = { "apprentice", "mechanic", "boss" } },
    { name = "cardealer", ranks = { "salesman", "manager", "owner" } }
}

-- Postboten-Job
Config.PostmanJob = {
    JobName = "postman", -- Name des Jobs
    Salary = 500, -- Gehalt pro Zustellung
    MaxDeliveries = 10, -- Maximale Anzahl von Zustellungen pro Schicht
    DeliveryTime = 300, -- Zeit in Sekunden, um eine Zustellung zu erledigen

    -- Level-System
    Levels = {
        { level = 1, xpRequired = 0, unlocks = "briefe" }, -- Nur Briefe
        { level = 5, xpRequired = 1000, unlocks = "pakete" }, -- Pakete freischalten
        { level = 10, xpRequired = 5000, unlocks = "illegale_pakete" } -- Illegale Pakete freischalten
    },

    -- XP-Belohnungen
    XPRewards = {
        briefe = 50, -- XP für Briefe 
        pakete = 100, -- XP für Pakete
        illegale_pakete = 200 -- XP für illegale Pakete
    },

    -- Fahrzeuge für Postboten
    Vehicles = {
        { model = "boxville", label = "Post-LKW" }, -- Beispiel: Boxville (Post-LKW)
        { model = "faggio", label = "Post-Moped" }  -- Beispiel: Faggio (Post-Moped)
    },

    -- Jobannahme-Stelle
    JobLocation = {
        x = 248.6752, -- X-Koordinate
        y = -825.1993, -- Y-Koordinate 
        z = 29.8444, -- Z-Koordinate
        heading = 337.4777 -- Ausrichtung
    }
}

-- Briefkasten-Item
Config.MailboxItem = "mailbox" -- Item-Name für den Briefkasten (muss in der Datenbank existieren)