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
