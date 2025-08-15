Config = {}

if not vector3 then
    vector3 = function(x, y, z)
        return {x = x, y = y, z = z}
    end
end

-- Jahreszeiten & Temperaturen
Config.SeasonDurationSeconds = 600 -- Dauer einer Jahreszeit in Sekunden
Config.TemperatureChangeIntervalMinutes = 15 -- Temperaturänderungsintervall

Config.Seasons = {
    {name = "Frühling", min_temp = 8,  max_temp = 18},
    {name = "Sommer",   min_temp = 20, max_temp = 40},
    {name = "Herbst",   min_temp = 10, max_temp = 20},
    {name = "Winter",   min_temp = -10, max_temp = 5}
}
Config.HeatwaveTemperature = 30 -- Hitzeperiode ab dieser Temperatur

-- Beispiel-Event-Orte (Ostereier)
Config.EggLocations = {
    [1] = vector3(214.9390, -807.937, 31.014),
    [2] = vector3(218.6911, -934.990, 28.652),
    [3] = vector3(285.1620, -985.747, 47.897),
    [4] = vector3(426.7019, -1014.453, 28.286),
    [5] = vector3(335.4664, -1080.561, 28.461),
    [6] = vector3(179.5521, -1070.91, 76.573),
    [7] = vector3(18.3839, -1101.7729, 29.7970),
    [8] = vector3(-119.1553, -977.089, 303.585),
    [9] = vector3(-80.0684, -823.759, 320.364),
    [10] = vector3(-235.5951, -2003.07, 23.756),
    [11] = vector3(29.9850, -1353.4147, 29.3274),
    [12] = vector3(970.6054, -108.998, 79.075),
    [13] = vector3(-1796.47, 170.6798, 65.282),
    [14] = vector3(-1464.09, 183.92, 54.918),
    [15] = vector3(-1059.35, 7.56, 51.4),
    [16] = vector3(-895.74, 156.77, 68.5562),
    [17] = vector3(-423.19, 1108.34, 331.67),
    [18] = vector3(268.5049, 840.53, 198.99),
    [19] = vector3(14.7459, 340.0324, 110.45),
    [20] = vector3(-357.0606, 180.347, 86.963),
    [21] = vector3(-126.6686, -140.554, 93.136),
    [22] = vector3(-1773.18, 452.0569, 128.133),
    [23] = vector3(-1915.59, -397.2446, 47.716),
    [24] = vector3(-1932.08, -435.644, 27.371),
    [25] = vector3(-1860.83, -339.454, 56.238),
    [26] = vector3(-1294.76, -574.796, 43.624),
    [27] = vector3(-584.1412, -1070.1351, 22.3297),
    [28] = vector3(-1626.0, -1098.936, 12.139),
    [29] = vector3(-955.09, -2637.886, 37.081),
    [30] = vector3(-52.63, -2747.81, 10.555),
    [31] = vector3(129.36, -3030.93, 7.015),
    [32] = vector3(579.625, -2971.44, 22.174),
    [33] = vector3(931.413, -3039.19, 16.194),
    [34] = vector3(936.314, -2965.57, 43.837),
    [35] = vector3(1174.83, -1494.19, 51.143),
    [36] = vector3(1073.52, -684.26, 56.903),
    [37] = vector3(1365.09, -581.29, 73.454),
    [38] = vector3(1148.78, -327.96, 68.236),
    [39] = vector3(987.29, 58.63, 110.330),
    [40] = vector3(1149.53, 124.79, 81.229),
    [41] = vector3(1246.63, 430.38, 103.541),
    [42] = vector3(276.634, 388.658, 118.629),
    [43] = vector3(1040.58, -732.63, 57.898),
    [44] = vector3(1041.981, -796.338, 58.127),
    [45] = vector3(1533.6141, 3780.7549, 34.5154),
    [46] = vector3(2008.892, 3934.544, 32.383),
    [47] = vector3(2708.208, 4318.733, 45.852),
    [48] = vector3(-240.036, 6600.625, 2.229),
    [49] = vector3(-285.124, 6309.667, 31.492),
    [50] = vector3(-544.391, 5367.270, 70.549)
}

-- Survival-Einstellungen
Config.Survival = {
    CheckIntervalSeconds = 30, -- Überprüfungsintervall
    HotTemperature = 28,       -- Schwelle für Hitze
    ThirstRate = 4000,         -- Durst-Rate
    HeatDamage = 5,            -- Schaden bei Hitze
    ClothingMultiplier = 1.5,  -- Multiplikator wenn warme Kleidung bei Hitze
    ColdTemperature = 0,       -- Schwelle für Kälte
    FreezingDamage = 3         -- Schaden bei Kälte
}

-- Warme Kleidung (IDs)
Config.WarmClothing = {
    jackets = {
        [15] = true, [25] = true, [26] = true, [31] = true, [32] = true, [33] = true,
        [47] = true, [50] = true, [51] = true, [55] = true, [69] = true, [94] = true,
        [121] = true, [124] = true, [131] = true
    },
    pants = {}
}

-- Herbst-Event
Config.AutumnEvent = {
    Enabled = true,
    DurationDays = 7,
    PumpkinLocations = {
        vector3(214.9, -807.9, 31.0),
        vector3(218.6, -934.9, 28.6),
        vector3(285.1, -985.7, 47.8)
    },
    Rewards = {
        common = {
            {type = "item", name = "pumpkin_pie", amount = 1},
            {type = "money", amount = {min = 100, max = 250}}
        },
        rare = {
            {type = "item", name = "scary_mask", amount = 1},
            {type = "money", amount = {min = 500, max = 1000}}
        },
        very_rare = {
            {type = "item", name = "rare_halloween_vehicle_key", amount = 1},
            {type = "money", amount = {min = 5000, max = 10000}}
        }
    },
    RewardProbabilities = {common = 70, rare = 25, very_rare = 5}
}

-- Winter-Event
Config.WinterEvent = {
    Enabled = true,
    DurationDays = 7,
    PresentLocations = {
        vector3(-80.0, -823.7, 320.3),
        vector3(-235.5, -2003.0, 23.7),
        vector3(29.9, -1353.4, 29.3)
    },
    Rewards = {
        common = {
            {type = "item", name = "hot_chocolate", amount = 1},
            {type = "money", amount = {min = 100, max = 250}}
        },
        rare = {
            {type = "item", name = "christmas_sweater", amount = 1},
            {type = "money", amount = {min = 500, max = 1000}}
        },
        very_rare = {
            {type = "item", name = "rare_winter_vehicle_key", amount = 1},
            {type = "money", amount = {min = 5000, max = 10000}}
        }
    },
    RewardProbabilities = {common = 70, rare = 25, very_rare = 5}
}

-- Dynamische Events (inkl. Glatteis)
Config.DynamicEvents = {
    CheckIntervalMinutes = 5, -- Prüfintervall für Zufallsevents
    PowerOutage = {
        Chance = 0.20, -- 20% Chance
        DurationMinutes = {min = 3, max = 8},
        Locations = {
            {name = "Rockford Hills", coords = vector3(-816.0, 178.0, 72.0), radius = 300.0},
            {name = "Vinewood", coords = vector3(230.0, 185.0, 105.0), radius = 250.0}
        }
    },
    Bushfire = {
        Chance = 0.15,
        Locations = {
            vector3(2450.0, 4970.0, 46.0),
            vector3(-1500.0, 4600.0, 40.0)
        }
    },
    Blizzard = {
        Chance = 0.30,
        BlockedRoads = {
            {name = "Great Ocean Highway", coords = vector3(-2400.0, 2400.0, 10.0)},
            {name = "Paleto Bay", coords = vector3(150.0, 6600.0, 31.0)}
        }
    },
    Glatteis = {
        Chance = 0.25, -- 25% Wahrscheinlichkeit bei Event-Check
        MinTemp = 0, -- Nur aktiv wenn Temperatur unter 0°C
        DurationMinutes = {min = 5, max = 30}, -- Dauer des Events
        GripReduction = 0.5, -- Haftungsverlust (0.5 = 50% weniger Grip)
        AnnouncementStart = "⚠ Achtung! Glatteis auf den Straßen – fahrt vorsichtig!",
        AnnouncementEnd = "✅ Das Glatteis ist verschwunden, Straßen wieder sicher."
    }
}
