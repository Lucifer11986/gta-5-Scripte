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
Config.Motives = {
    "Motiv 1",  -- Motiv 1 als Beispiel
    "Motiv 2",  -- Motiv 2
    "Motiv 3"   -- Motiv 3
}
