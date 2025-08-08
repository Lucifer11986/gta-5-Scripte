fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Boni Prüfung'
version '2.0.0'

lua54 'yes'

-- Escrow-Schutz aktivieren
escrow_ignore {
    'config.lua',
    'README.md'
}
 
shared_scripts {
    'config.lua',
	'@es_extended/imports.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependency '/assetpacks'
