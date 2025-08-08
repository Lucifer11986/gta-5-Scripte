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
Config.DeliveryFee = 100
Config.ExpressMultiplier = 3
Config.ExpressDeliveryTime = 5
Config.StandardDeliveryTime = 120

-- Briefmarken-System
Config.StampPrice = 50
Config.StampItem = "stamp"

-- Postfach-Kapazität
Config.MailboxCapacity = 20

-- Job, zu dem der Spieler nach der Schicht zurückkehrt
Config.DefaultJob = {
    JobName = "unemployed",
    Grade = 0
}

-- Postboten-Job
Config.PostmanJob = {
    JobName = "postman",
    Salary = 500,
    MaxDeliveries = 10,
    DeliveryTime = 300,

    JobLocation = {
        x = 399.8, y = -847.4, z = 29.4
    },

    Uniform = {
        male = {
            tshirt_1 = 15, tshirt_2 = 0,
            torso_1 = 55, torso_2 = 2,
            arms = 1,
            pants_1 = 25, pants_2 = 0,
            shoes_1 = 24, shoes_2 = 0,
        },
        female = {
            tshirt_1 = 15, tshirt_2 = 0,
            torso_1 = 14, torso_2 = 2,
            arms = 5,
            pants_1 = 34, pants_2 = 0,
            shoes_1 = 24, shoes_2 = 0,
        }
    }
}

-- Briefkasten-System
Config.MailboxItem = "mailbox_item"
Config.MailboxProp = `prop_postbox_01a`

-- Fraktionen/Gruppen (Beispiel)
Config.Factions = {
    { name = "police", ranks = { "recruit", "officer", "chief" } },
    { name = "ambulance", ranks = { "paramedic", "doctor", "chief" } }
}
