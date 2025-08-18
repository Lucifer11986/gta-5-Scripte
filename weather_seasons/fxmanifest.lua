fx_version 'cerulean'
game 'gta5'


author 'Lucifer | Awaria Modding - Edited by Jules'
description 'Dynamisches Wetter und Jahreszeiten mit Events und Survival-Mechaniken'
version '4.0.0' -- Finale Version

shared_script 'config.lua'

client_scripts {
    'client/survival_effects.lua',
    'client/environmental_effects.lua',
    'client/dynamic_events.lua',
    'client/vehicle_mods.lua',
    'client/oster_event.lua',
    'client/autumn_event.lua',
    'client/winter_event.lua',
    -- 'client/season_events.lua', -- DEAKTIVIERT
    'client/sommer_events.lua',
	'client/sommermarkt.lua',
    'client/plant_visuals.lua',
    'client/plant_interaction.lua',
    'client/plant_ui.lua',
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    -- 'server/weather_seasons.lua', -- DEAKTIVIERT, da es mit server.lua konfliktiert
    'server/survival_effects.lua',
    'server/dynamic_events.lua',
    'server/vehicle_mods.lua',
    'server/oster_event.lua',
    'server/autumn_event.lua',
    'server/winter_event.lua',
    'server/items.lua', -- Schneeketten-Logik
    -- 'server/season_events.lua', -- DEAKTIVIERT
    'server/sommer_events.lua',
	'server/sommermarkt.lua',
	'server/hitzwelle.lua', -- Beinhaltet Wasser-Battle Belohnungen
    'server/plant_growth.lua',
    'server/plant_effects.lua',
    'server/server.lua'
}

=======
author 'AbyssForge Studio'
description 'Dynamisches Wetter und Jahreszeiten'
version '2.3.0'


-- Geteilte Konfigurationsdatei
shared_script 'config.lua'

-- Client-Skripte
client_scripts {
    'client/client.lua',
    'client/oster_event.lua',
    'client/autumn_event.lua',
    'client/winter_event.lua',
    'client/vehicle_mods.lua',
    -- 'client/season_events.lua', -- (DEAKTIVIERT)
    'client/plant_visuals.lua',
    'client/plant_interaction.lua',
    'client/plant_ui.lua',
    'client/sommer_events.lua',
    'client/sommermarkt.lua',
    'client/survival_effects.lua',
    'client/environmental_effects.lua',
    'client/dynamic_events.lua' -- NEU
}

-- Server-Skripte
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    -- '@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'server/oster_event.lua',
    'server/autumn_event.lua',
    'server/winter_event.lua',
    'server/weather_seasons.lua',
    'server/items.lua',
    'server/vehicle_mods.lua',
    -- 'server/season_events.lua', -- (DEAKTIVIERT)
    'server/plant_growth.lua',
    'server/plant_effects.lua',
    'server/sommer_events.lua',
    'server/sommermarkt.lua',
    'server/hitzwelle.lua',
    'server/survival_effects.lua',
    'server/dynamic_events.lua' -- NEU
}

-- Stream-Ordner für 3D-Modelle

files {
    -- Ostern
    'stream/core_eggs.ytyp',
    'stream/core_egg01.ydr',
    'stream/core_egg02.ydr',
    'stream/core_egg03.ydr',
    'stream/core_egg04.ydr',
    'stream/core_egg05.ydr',

    'stream/core_egg06.ydr'
}

data_file 'DLC_ITYP_REQUEST' 'core_eggs.ytyp'


    'stream/core_egg06.ydr',

    -- Herbst & Winter
    'stream/prop_pumpkin_01.ydr',
    'stream/prop_xmas_present_01.ydr'
}

data_file 'DLC_ITYP_REQUEST' 'stream/core_eggs.ytyp'

-- Escrow Protection

escrow_ignore {
    'config.lua'
}


=======
-- Abhängigkeiten

dependencies {
    'es_extended',
    'oxmysql'
}
