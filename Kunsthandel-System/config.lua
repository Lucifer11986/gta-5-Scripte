Config = {}

Config.Framework = 'esx' -- 'esx' oder 'qb'

-- Taste für die Interaktion (siehe https://docs.fivem.net/docs/game-references/controls/)
Config.InteractionKey = 38 -- E

Config.MarketLocations = {
    {coords = vector3(-1160.85, -1565.99, 4.66), type = 'legal', blip = true},
    {coords = vector3(1247.56, -2571.34, 42.79), type = 'illegal', blip = false}
}

-- Job, der einen Rabatt erhält
Config.DiscountJob = 'kunsthaendler'
-- Rabatt in Prozent (z.B. 0.8 für 20% Rabatt)
Config.DiscountAmount = 0.8

-- Multiplikator für den Verkaufspreis (z.B. 0.5 für 50% des Originalpreises)
Config.SellMultiplier = 0.5

-- Blip-Einstellungen für legale Händler
Config.BlipSettings = {
    sprite = 439, -- Blip-Sprite
    display = 4,
    scale = 0.8,
    color = 2,
    name = "Kunsthändler"
}
