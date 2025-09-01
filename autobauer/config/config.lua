Config = {}

-- =========================
-- Framework Einstellung
-- =========================
Config.Framework = "ESX" -- Wähle zwischen "ESX" oder "QBCore"

-- =========================
-- Datenbank Einstellungen
-- =========================
-- Typ: "oxmysql" (empfohlen) oder "async"
Config.DBType = "oxmysql"

-- =========================
-- Job Einstellungen
-- =========================
-- Fallback Jobname falls kein JobCreator genutzt wird
Config.JobName = "autobauer"

-- Liste kompatibler Jobs (für JobCreator & Co.)
Config.AllowedFactoryJobs = {
    ["autobauer"] = true,
    ["car_factory"] = true,
    ["factory_worker"] = true,
    ["Autobauer GmbH"] = true
}

-- =========================
-- Materialien
-- =========================
Config.Materials = {
    {name="iron", label="Eisenbarren"},
    {name="rubber", label="Gummi"},
    {name="leather", label="Leder"},
    {name="electronics", label="Elektroteile"},
    {name="fabric_red", label="Roter Stoff"}
}

-- =========================
-- Fahrzeuge
-- =========================
-- Felder:
-- name       = Spawnname / Model
-- label      = Anzeigename
-- category   = PKW | Trucks | Busse | Bikes
-- fuel       = Super | Diesel | Elektro
-- requirements = Rohstoffe für Produktion
-- price      = Standardpreis (kann später im UI angepasst werden)
Config.Vehicles = {
    {
        name="adder",
        label="Adder Sportwagen",
        category="PKW",
        fuel="Super",
        requirements={iron=20, rubber=10, electronics=5, leather=5, fabric_red=2},
        price=500000
    },
    {
        name="zentorno",
        label="Zentorno Supersportwagen",
        category="PKW",
        fuel="Super",
        requirements={iron=25, rubber=12, electronics=8, leather=6, fabric_red=3},
        price=750000
    },
    {
        name="man_truck",
        label="MAN Truck",
        category="Trucks",
        fuel="Diesel",
        requirements={iron=40, rubber=15, electronics=10, leather=8},
        price=1200000
    },
    {
        name="volvo_bus",
        label="Volvo Reisebus",
        category="Busse",
        fuel="Diesel",
        requirements={iron=50, rubber=20, electronics=15, fabric_red=5},
        price=1500000
    },
    {
        name="bati",
        label="Bati 801",
        category="Bikes",
        fuel="Super",
        requirements={iron=10, rubber=5, electronics=3, leather=2},
        price=30000
    },
    {
        name="neon_ev",
        label="Neon Elektro",
        category="PKW",
        fuel="Elektro",
        requirements={iron=18, rubber=8, electronics=12, fabric_red=1},
        price=650000
    }
}

-- =========================
-- Produktionszeit (Sekunden)
-- =========================
Config.ProductionTime = {
    ["adder"]      = 900,   -- 15 Min
    ["zentorno"]   = 1200,  -- 20 Min
    ["man_truck"]  = 1800,  -- 30 Min
    ["volvo_bus"]  = 2400,  -- 40 Min
    ["bati"]       = 600,   -- 10 Min
    ["neon_ev"]    = 1000   -- ~17 Min
}
