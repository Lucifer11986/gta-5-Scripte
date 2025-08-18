--config.lua


config = {}

-- Marktposition
config.MarketPosition = {
    x = 251.62,
    y = 221.7,
    z = 106.29,
    h = 338.71
}

-- Marker Einstellungen
config.Marker = {
    type = 1,
    scale = { x = 1.5, y = 1.5, z = 1.0 },
    color = { r = 0, g = 255, b = 0, a = 100 }
}

-- Blip Einstellungen
config.Blip = {
    sprite = 389,
    color = 2,
    scale = 1.0,
    name = "Aktienmarkt"
}

-- Marker-Distanz
config.markerDistance = 2.0

-- Preisänderungen und andere spezielle Funktionen können hier definiert werden
-- Beispiel:
config.priceChangeRate = 0.1  -- Beispielwert für die Preisänderungsrate