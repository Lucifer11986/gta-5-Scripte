fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Boni Prüfung'
version '2.0.0'

lua54 'yes'
-- Escrow-Schutz aktivieren
escrow_ignore {
    'config.lua', -- Konfigurationsdatei von Escrow-Schutz ausnehmen
    'readme.txt'
}

 
shared_scripts {
    'config.lua', -- Konfigurationsdatei
	'@es_extended/imports.lua'
}

client_scripts {
    'client/main.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

-- Exportierte Funktionen
exports {
    'ShowTemporaryNotification'
}

dependency '/assetpacks'
