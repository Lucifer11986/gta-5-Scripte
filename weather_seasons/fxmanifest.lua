fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Dynamisches Wetter und Jahreszeiten'
version '2.0.0'

-- Client-Skripte
client_scripts {
    'client/client.lua',
    'client/oster_event.lua', -- Oster-Event
    -- 'client/season_events.lua', -- Start Kirschblüten-Event (DEAKTIVIERT, um Konflikt zu lösen)
    'client/plant_visuals.lua',  -- Pflanzenwachstum
    'client/plant_interaction.lua', -- Pflanzenwettereffekte
    'client/plant_ui.lua',
    'client/sommer_events.lua', -- Sommer-Events (Wasser-Battle und Ernte-Wettbewerb bereits hier)
	'client/sommermarkt.lua', -- Sommermarket
    'client/survival_effects.lua', -- NEU: Clientseitige Überlebens-Effekte
    'config.lua' -- config.lua wird nicht unter Escrow-Schutz gestellt
}

-- Server-Skripte
server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Standardmäßig OxMySQL nutzen
    -- '@mysql-async/lib/MySQL.lua', -- Falls 'async' genutzt wird, diese Zeile entkommentieren
    'server/server.lua',
    'server/oster_event.lua', -- Oster-Event
    'server/weather_seasons.lua',   -- Wettersteuerung
    -- 'server/season_events.lua', -- Ereignisse und Saisons (DEAKTIVIERT, um Konflikt zu lösen)
    'server/plant_growth.lua',  -- Pflanzenwachstum
    'server/plant_effects.lua', -- Pflanzenwettereffekte
    'server/sommer_events.lua',	-- Sommer-Events (Wasser-Battle und Ernte-Wettbewerb bereits hier)
	'server/sommermarkt.lua', -- Sommermarket
	'server/hitzwelle.lua',
    'server/survival_effects.lua', -- NEU: Serverseitige Überlebens-Effekte
    'config.lua' -- config.lua wird nicht unter Escrow-Schutz gestellt
}

-- Geteilte Konfigurationsdatei
shared_script 'config.lua'

-- Stream-Ordner für 3D-Osterei-Modelle
files {
    'stream/core_eggs.ytyp',
    'stream/core_egg01.ydr',
    'stream/core_egg02.ydr',
    'stream/core_egg03.ydr',
    'stream/core_egg04.ydr',
    'stream/core_egg05.ydr',
    'stream/core_egg06.ydr'
}

data_file 'DLC_ITYP_REQUEST' 'core_eggs.ytyp'

-- Escrow Protection
escrow_ignore {
    'config.lua', -- config.lua von Escrow-Schutz ausnehmen
}

-- Abhängigkeiten
dependencies {
    'es_extended', -- ESX Legacy
    'oxmysql' -- Sicherstellen, dass OxMySQL als Abhängigkeit vorhanden ist
}
