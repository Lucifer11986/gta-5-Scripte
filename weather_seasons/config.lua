Config = {
    someConfigOption = "value",
    anotherConfigOption = 42
}

Config.DeliveryFee = 100  -- Standard-Versandgebühr
Config.ExpressMultiplier = 2  -- Expressversand kostet das Doppelte

Config.SeasonDuration = 600 -- Zeit in Sekunden pro Saison (300 für Testzwecke, 600 für regulär)
Config.Seasons = {
    {name = "Frühling", min_temp = 8,  max_temp = 18},
    {name = "Sommer",   min_temp = 20, max_temp = 35},
    {name = "Herbst",   min_temp = 10, max_temp = 20},
    {name = "Winter",   min_temp = -5, max_temp = 5}
}
Config.HeatwaveTemperature = 30

Config.WeatherTypes = {'CLEAR', 'EXTRASUNNY', 'CLOUDS', 'RAIN', 'THUNDER', 'SNOW'}

Config.SeasonEffects = {
    Fruehling = {weather = 'CLEAR', temp = 'mild', effect = 'blossoming_flowers'},
    Sommer = {weather = 'EXTRASUNNY', temp = 'hot', effect = 'bright_sun'},
    Herbst = {weather = 'CLOUDS', temp = 'cool', effect = 'falling_leaves'},
    Winter = {weather = 'SNOW', temp = 'cold', effect = 'snowflakes'},
}

-- Koordinaten des Kirschblüten-Festivals
Config.BlossomFestivalLocations = {
    {x = 2049.84, y = 3455.43, z = 43.8}, -- Beispiel-Koordinaten
    {x = 2345.67, y = -2345.67, z = 31.0},
    {x = 3456.78, y = -3456.78, z = 32.0},
    {x = 1084.76, y = -696.92, z = 58.01} -- Weitere Koordinaten für das Festival
}

-- Sicherstellen, dass vector3 definiert ist
if not vector3 then
    vector3 = function(x, y, z)
        return {x = x, y = y, z = z}
    end
end

-- Koordinaten der Ostereier
Config.EggLocations = {
    [1] = vector3(214.9390, -807.937, 31.014), -- Egg 1 >> Parking Lot Booth at Legion Sq
    [2] = vector3(218.6911, -934.990, 28.652), -- Egg 2 >> In Legion Sq
    [3] = vector3(285.1620, -985.747, 47.897), -- Egg 3 >> Aley Way Across from Legion Sq
    [4] = vector3(426.7019, -1014.453, 28.286), -- Egg 4 >> MRPD (Mission Row PD) {This may be in the open if using default PD IDK, I placed this in GABZ MRPD enabled}
    [5] = vector3(335.4664, -1080.561, 28.461), -- Egg 5 >> Homeless Aley down the road from MRPD
    [6] = vector3(179.5521, -1070.91, 76.573), -- Egg 6 >> Top of the Climable Roof that had the Fire Exit behind the Fleeca Bank in Legion Sq
    [7] = vector3(18.3839, -1101.7729, 29.7970), -- Egg 7 >> Legion Sq Ammunation {This may be in the open/hidden if using default Ammunation IDK, I placed this in GABZ Ammunation enabled}
    [8] = vector3(-119.1553, -977.089, 303.585), -- Egg 8 >> At the VERY Top of the Biggest Crane in San Andreas, Tallest crane for the Mile High Club (If you have the MLO, you'll have to move this)
    [9] = vector3(-80.0684, -823.759, 320.364), -- Egg 9 >> Top of the Maze Bank Tower
    [10] = vector3(-235.5951, -2003.07, 23.756), -- Egg 10 >> Fame or Shame in the Maze Bank Arena (Needs the IPL loaded)
    [11] = vector3(29.9850, -1353.4147, 29.3274), -- Egg 11 >> Strawberry 24/7 on Innocence Blvd
    [12] = vector3(970.6054, -108.998, 79.075), -- Egg 12 >> Lost CH Roof
    [13] = vector3(-1796.47, 170.6798, 65.282), -- Egg 13 >> Hidden Around the Race Track of the University
    [14] = vector3(-1464.09, 183.92, 54.918), -- Egg 14 >> Swimming Pool Cave in the Playboy Mansion
    [15] = vector3(-1059.35, 7.56, 51.4), -- Egg 15 >> Somewhere on the Golf Course
    [16] = vector3(-895.74, 156.77, 68.5562), -- Egg 16 >> Construction Site opposite Micheal's house
    [17] = vector3(-423.19, 1108.34, 331.67), -- Egg 17 >> Roof of Galileo Observatory
    [18] = vector3(268.5049, 840.53, 198.99), -- Egg 18 >> Between some Trees on the East Side of Lake Vinewood (Inside the Fence Line)
    [19] = vector3(14.7459, 340.0324, 110.45), -- Egg 19 >> An Under passage? in the Gentry Manor Hotel opposite Up-n-Atom
    [20] = vector3(-357.0606, 180.347, 86.963), -- Egg 20 >> Back side by the pools of the Hotel next to the Vinewood Strip Club/Opposite the Last Train of Los Santos
    [21] = vector3(-126.6686, -140.554, 93.136), -- Egg 21 >> ON the Highest Point of the Roof of the Rockford Plaza (Yes you can get up there without No-Clip, the stairs are on the side the LS Customs is)
    [22] = vector3(-1773.18, 452.0569, 128.133), -- Egg 22 >> Large Mansion in Richman by the long, thin pool on the Upper Level
    [23] = vector3(-1915.59, -397.2446, 47.716), -- Egg 23 >> On top of a Floaty by the Pool of the VON CRASTENBURG
    [24] = vector3(-1932.08, -435.644, 27.371), -- Egg 24 >> Sat on a Bench, just chilling looking over the beach opposite the VON CRASTENBURG
    [25] = vector3(-1860.83, -339.454, 56.238), -- Egg 25 >> On the Bridge that Crosses over Del Perro Fwy, just down from the Bench of Egg 24
    [26] = vector3(-1294.76, -574.796, 43.624), -- Egg 26 >> On the roof of the City Hall (Can be accessed from the back of the building)
    [27] = vector3(-584.1412, -1070.1351, 22.3297), -- Egg 27 >> Resting on the Tree of the UwU-Cat-Cafe (Gabz's UwU-Cat-Cafe is required for this one, otherwise you need to move this one)
    [28] = vector3(-1626.0, -1098.936, 12.139), -- Egg 28 >> In the Tattoo and Piercing Stool on the Pier, next to the Drop Tower
    [29] = vector3(-955.09, -2637.886, 37.081), -- Egg 29 >> On one of the Parking Lots in LSIA (It is on the Top of the Staircase shelter on the Top Level)
    [30] = vector3(-52.63, -2747.81, 10.555), -- Egg 30 >> In one of the Boat Docks on Elysian Island, by the "OLIFANTUS" Ship
    [31] = vector3(129.36, -3030.93, 7.015), -- Egg 31 >> Inside the Tuner Garage on Elysian Island (Requires GABZ's Tuner Garage, if you don’t have it then you’ll have to move this one)
    [32] = vector3(579.625, -2971.44, 22.174), -- Egg 32 >> On top of a crane outside the Merry Weather Port (Can be accessed with Ladders/Stairs)
    [33] = vector3(931.413, -3039.19, 16.194), -- Egg 33 >> On top of some Containers on the Dock, near the Center (You have to climb one of the Dock Cranes to access these Containers, the Crane is level with the Containers)
    [34] = vector3(936.314, -2965.57, 43.837), -- Egg 34 >> On Top of one of the Bigger Container Cranes next to Cargo Ship "Ocean Motion" (Can be accessed with Ladders)
    [35] = vector3(1174.83, -1494.19, 51.143), -- Egg 35 >> Located at Fire Station 7 in El Burro Heights (No MLO is needed for this one)
    [36] = vector3(1073.52, -684.26, 56.903), -- Egg 36 >> Mirror Park Lake Somewhere
    [37] = vector3(1365.09, -581.29, 73.454), -- Egg 37 >> Housing Cul-de-sac
    [38] = vector3(1148.78, -327.96, 68.236), -- Egg 38 >> Mirror Park Gas Station
    [39] = vector3(987.29, 58.63, 110.330), -- Egg 39 >> Chilling to a Nice Diamond Casino Security Guard on the Roof at the Back side
    [40] = vector3(1149.53, 124.79, 81.229), -- Egg 40 >> Building across from the Diamond Casino
	[41] = vector3(1246.63, 430.38, 103.541), -- Egg 41 >> The Liberty Tower
    [42] = vector3(276.634, 388.658, 118.629), -- Egg 42 >> On top of a crane near the back side of LSIA
	[43] = vector3(1040.58, -732.63, 57.898),   -- Egg 43 >> Mirrow Park am Baum gegenüber des Parkplatzes
	[44] = vector3(1041.981, -796.338, 58.127), --Egg 44 >> Parkplatz Mirrowpark
	[45] = vector3(1533.6141, 3780.7549, 34.5154),
	[46] = vector3(2008.892, 3934.544, 32.383),
	[47] = vector3(2708.208, 4318.733, 45.852),
	[48] = vector3(-240.036, 6600.625, 2.229),
	[49] = vector3(-285.124, 6309.667, 31.492),
	[50] = vector3(-544.391, 5367.270, 70.549),
}

Config.TemperatureColorChange = true
Config.BossLocation = vector3(2452.321, 2687.163, 55.018) -- Der Boss kann in diesen Bereichen sein

-- 🌞 Sommer-Event Konfiguration
Config.SummerEvent = {
    StartDate = {month = 6, day = 21}, -- Startdatum des Sommer-Events
    EndDate = {month = 9, day = 21},   -- Enddatum des Sommer-Events
    HeatwaveTemperature = 35,          -- Temperatur während einer Hitzewelle
    DehydrationRate = 0.05,            -- Wie schnell Spieler ohne Wasser dehydrieren
    WaterRestoreAmount = 50,           -- Wie viel Wasser ein Getränk wiederherstellt
}

-- 🏖️ Strand-Partys
Config.BeachPartyLocations = {
    vector3(-1600.0, -1040.0, 13.0),  -- Vespucci Beach
    vector3(-1800.0, -1200.0, 13.0),  -- Del Perro Beach
    vector3(-1400.0, -980.0, 13.0),   -- Santa Maria Beach
}

Config.BeachPartyMusic = {
    "summer_tune_1.mp3",
    "beach_party_vibes.mp3",
    "chill_summer_mix.mp3"
}

-- 🔥 Hitze-Mechanik
Config.EnableHeatMechanic = true
Config.HeatDamagePerSecond = 1  -- Schaden pro Sekunde bei extremer Hitze

-- 🔍 Sommerschatzsuche (Vergrabene Truhen)
Config.TreasureLocations = {
    vector3(-1650.0, -1050.0, 12.0),
    vector3(-1700.0, -1100.0, 12.5),
    vector3(-1750.0, -1150.0, 11.8),
}

Config.TreasureRewards = {
    {item = "gold_bar", amount = 1},
    {item = "rare_pearl", amount = 2},
    {item = "mystery_key", amount = 1},
}

-- 🏐 Sommer-Mini-Spiele
Config.EnableMiniGames = true
Config.MiniGameLocations = {
    {type = "volleyball", pos = vector3(-1620.0, -1020.0, 13.0)},
    {type = "jet_ski_race", pos = vector3(-1800.0, -1250.0, 13.0)}
}

-- 🌦️ Sommer-Wetter Dynamik
Config.SummerWeather = {"EXTRASUNNY", "CLEAR", "CLOUDS"}
Config.SummerNightWeather = {"CLEAR", "FOGGY"}

-- 🌡️ Überlebens-Mechaniken
Config.Survival = {
    CheckInterval = 30,
    HotTemperature = 28,
    ThirstRate = 2,
    HeatDamage = 5,
    ClothingMultiplier = 1.5,
    ColdTemperature = 0,
    FreezingDamage = 3
}

-- Kleidungskonfiguration
Config.WarmClothing = {
    jackets = { [15]=true, [25]=true, [26]=true, [31]=true, [32]=true, [33]=true, [47]=true, [50]=true, [51]=true, [55]=true, [69]=true, [94]=true, [121]=true, [124]=true, [131]=true },
    pants = {}
}

-- 🎃 Herbst-Event
Config.AutumnEvent = {
    Enabled = true,
    DurationDays = 7,
    PumpkinLocations = { vector3(214.9, -807.9, 31.0), vector3(218.6, -934.9, 28.6), vector3(285.1, -985.7, 47.8) },
    Rewards = {
        common = { { type = "item", name = "pumpkin_pie", amount = 1 }, { type = "money", amount = {min = 100, max = 250} } },
        rare = { { type = "item", name = "scary_mask", amount = 1 }, { type = "money", amount = {min = 500, max = 1000} } },
        very_rare = { { type = "item", name = "rare_halloween_vehicle_key", amount = 1 }, { type = "money", amount = {min = 5000, max = 10000} } }
    },
    RewardProbabilities = { common = 70, rare = 25, very_rare = 5 }
}

-- ⚡ Dynamische Wetter-Events
Config.DynamicEvents = {
    CheckIntervalMinutes = 5,
    PowerOutage = {
        Chance = 0.20,
        DurationMinutes = { min = 3, max = 8 },
        Locations = { { name = "Rockford Hills", coords = vector3(-816.0, 178.0, 72.0), radius = 300.0 }, { name = "Vinewood", coords = vector3(230.0, 185.0, 105.0), radius = 250.0 } }
    },
    Bushfire = {
        Chance = 0.15,
        Locations = { vector3(2450.0, 4970.0, 46.0), vector3(-1500.0, 4600.0, 40.0) }
    },
    Blizzard = {
        Chance = 0.30,
        BlockedRoads = { { name = "Great Ocean Highway", coords = vector3(-2400.0, 2400.0, 10.0) }, { name = "Paleto Bay", coords = vector3(150.0, 6600.0, 31.0) } }
    }
}

-- 🎁 Winter-Event
Config.WinterEvent = {
    Enabled = true,
    DurationDays = 7,
    PresentLocations = { vector3(-80.0, -823.7, 320.3), vector3(-235.5, -2003.0, 23.7), vector3(29.9, -1353.4, 29.3) },
    Rewards = {
        common = { { type = "item", name = "hot_chocolate", amount = 1 }, { type = "money", amount = {min = 100, max = 250} } },
        rare = { { type = "item", name = "christmas_sweater", amount = 1 }, { type = "money", amount = {min = 500, max = 1000} } },
        very_rare = { { type = "item", name = "rare_winter_vehicle_key", amount = 1 }, { type = "money", amount = {min = 5000, max = 10000} } }
    },
    RewardProbabilities = { common = 70, rare = 25, very_rare = 5 }
}