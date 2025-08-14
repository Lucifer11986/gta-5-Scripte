Config = {}

-- Preise für Spraydosen und spezielle Spray-Techniken
Config.SprayCanPrice = 50
Config.SpecialSprayPrice = 200

-- Schwarzmarkt-Preise für exklusive Farben
Config.BlackMarketPrices = {
    chrome = 500,
    holographic = 750,
    fire = 1000
}

-- Maximale Anzahl an Spraydosen im Inventar
Config.MaxSprayCans = 10

-- Anti-Spam: Mindestabstand zwischen zwei Graffitis (in Metern)
Config.MinDistanceBetweenGraffiti = 5.0

-- Zeit in Sekunden, nach der ein Graffiti automatisch verschwindet.
-- Setze auf 0, damit Graffitis nie von alleine verschwinden.
Config.GraffitiFadeTime = 24 * 3600 -- 24 Stunden

-- Farboptionen für Spraydosen
Config.Colors = {
    red = "Rot",
    blue = "Blau",
    green = "Grün",
    yellow = "Gelb",
    chrome = "Chrom",
    holographic = "Holographisch",
    fire = "Feuer"
}

-- Spray-Techniken
Config.SprayTechniques = {
    basic = { name = "Standard", price = Config.SprayCanPrice },
    name = { name = "Name-Spray", price = Config.SpecialSprayPrice },
    stencil = { name = "Stencil Art", price = Config.SpecialSprayPrice },
    uv = { name = "UV-Spray", price = Config.SpecialSprayPrice }
}

-- Graffiti-Motive
-- Each motif has a 'name' for the UI and a 'file' for the graffiti texture/decal name.
Config.Motives = {
    { name = "Tribal-Sonne", file = "graffiti_tribal_sun" },
    { name = "Gasmaske", file = "graffiti_gasmask" },
    { name = "Rose", file = "graffiti_rose" },
    { name = "Totenkopf", file = "graffiti_skull" },
    { name = "East Side", file = "graffiti_eastsid" }
}

-- Polizei-System Einstellungen
Config.PoliceSystem = {
    Enable = true, -- Soll das System aktiv sein?
    MinPoliceRequired = 2, -- Wie viele Polizisten müssen im Dienst sein?
    AlertChance = 0.3, -- 30% Chance auf einen Alarm
    BlipSprite = 1, -- Das Icon des Blips auf der Karte
    BlipColour = 1, -- Die Farbe des Blips (1 = Rot)
    BlipScale = 1.0, -- Die Größe des Blips
    BlipDuration = 60 -- Zeit in Sekunden, wie lange der Blip sichtbar ist
}
