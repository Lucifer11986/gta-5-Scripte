fx_version 'cerulean'
game 'gta5'

author 'AbyssForge Studio'
description 'Autobauer Job Script (ESX & QBCore kompatibel)'
version '1.0.0'

-- Abhängigkeiten
dependency 'oxmysql'

-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/config.lua',
    'server/callbacks.lua',
    'server/server.lua',
    'server/boss_server.lua'
}

-- Client Scripts
client_scripts {
    'config/config.lua',
    'client/client.lua',
    'client/boss.lua',
    'client/production.lua',
    'client/storage.lua'
}

-- NUI
ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js'
}
