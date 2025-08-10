Config = {}

-- Definition der Fahrstühle mit Koordinaten und Anforderungen für Jobs und Ränge
Config.Elevator = {
    -- Erster Fahrstuhl
    {
        floors = {
            {x = -1095.84, y = -850.77, z = 4.88, label = 'Etage -1'}, -- Etage -1
			{x = -1095.84, y = -850.77, z = 10.27, label = 'Etage -2'},  -- Etage -2
			{x = -1095.84, y = -850.77, z = 13.76, label = 'Etage-3'},  -- Etage -3
			{x = -1095.84, y = -850.44, z = 19.0, label = 'Erdgeschoss'},     -- Etage 0
			{x = -1095.84, y = -850.77, z = 23.03, label = 'Kantiene'},       -- Etage 1
			{x = -1095.84, y = -850.47, z = 26.82, label = 'Gym'},       -- Etage 2
			{x = -1095.84, y = -850.4, z = 30.76, label = 'Officer Büros'},         -- Etage 3
			{x = -1095.84, y = -850.32, z = 34.36, label = 'Chief Büros', job = 'police', rank = 4},       -- Etage 4
			{x = -1095.84, y = -850.37, z = 38.24, label = 'Helicopter Platz'},       -- Etage 5
        }
    },
    -- Zweiter Fahrstuhl
    {
        floors = {
            {x = 445.00, y = -984.80, z = 30.69, h = 331.15, label = 'Eingang'},
            {x = 464.5353, y = -987.5828, z = 24.9148, label = 'Zelle'}, --464.5353, -987.5828, 24.9148, 338.2584
            
        }
    },

    -- Test Fahrstuhl
    {
        floors = {
            {x = 212.2854, y = -922.9842, z = 30.6920, h = 229.2219, label = 'Eingang'},
            {x = 211.4016, y = -921.1183, z = 60.7195, label = 'Zelle'},
        }
    }
}
