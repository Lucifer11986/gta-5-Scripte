fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding - Edited by Jules'
description 'Dynamisches Wetter und Jahreszeiten mit Events und Survival-Mechaniken'
version '4.0.0' -- Finale Version

client_scripts {
    'config.lua',
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
    'config.lua',
    'server/weather_seasons.lua',
    'server/survival_effects.lua',
    'server/dynamic_events.lua',
    'server/vehicle_mods.lua',
    'server/oster_event.lua',
    'server/autumn_event.lua',
    'server/winter_event.lua',
    -- 'server/season_events.lua', -- DEAKTIVIERT
    'server/sommer_events.lua',
	'server/sommermarkt.lua',
	'server/hitzwelle.lua', -- Beinhaltet Wasser-Battle Belohnungen
    'server/plant_growth.lua',
    'server/plant_effects.lua',
    'server/server.lua'
}

shared_script 'config.lua'

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

escrow_ignore {
    'config.lua'
}

dependencies {
    'es_extended',
    'oxmysql'
}
