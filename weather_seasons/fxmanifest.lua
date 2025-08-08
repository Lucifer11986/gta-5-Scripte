fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Dynamisches Wetter und Jahreszeiten'
version '2.1.0' -- Version erhöht, da neue Features hinzugefügt wurden

-- Client-Skripte
client_scripts {
    'client/client.lua',
    'client/oster_event.lua',
    'client/autumn_event.lua', -- NEU
    'client/winter_event.lua', -- NEU
    -- 'client/season_events.lua', -- Start Kirschblüten-Event (DEAKTIVIERT, um Konflikt zu lösen)
    'client/plant_visuals.lua',
    'client/plant_interaction.lua',
    'client/plant_ui.lua',
    'client/sommer_events.lua',
	'client/sommermarkt.lua',
    'client/survival_effects.lua',
    'config.lua'
}

-- Server-Skripte
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    -- '@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'server/oster_event.lua',
    'server/autumn_event.lua', -- NEU
    'server/winter_event.lua', -- NEU
    'server/weather_seasons.lua',
    -- 'server/season_events.lua', -- (DEAKTIVIERT, um Konflikt zu lösen)
    'server/plant_growth.lua',
    'server/plant_effects.lua',
    'server/sommer_events.lua',
	'server/sommermarkt.lua',
	'server/hitzwelle.lua',
    'server/survival_effects.lua',
    'config.lua'
}

-- Geteilte Konfigurationsdatei
shared_script 'config.lua'

-- Stream-Ordner für 3D-Modelle
files {
    -- Ostern
    'stream/core_eggs.ytyp',
    'stream/core_egg01.ydr',
    'stream/core_egg02.ydr',
    'stream/core_egg03.ydr',
    'stream/core_egg04.ydr',
    'stream/core_egg05.ydr',
    'stream/core_egg06.ydr',

    -- Herbst & Winter (Platzhalter, durch eigene Modelle ersetzen)
    'stream/prop_pumpkin_01.ydr',
    'stream/prop_xmas_present_01.ydr'
}

data_file 'DLC_ITYP_REQUEST' 'core_eggs.ytyp'

-- Escrow Protection
escrow_ignore {
    'config.lua',
}

-- Abhängigkeiten
dependencies {
    'es_extended', -- ESX Legacy
    'oxmysql' -- Sicherstellen, dass OxMySQL als Abhängigkeit vorhanden ist
}
