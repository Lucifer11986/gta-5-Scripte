-- fxmanifest.lua

fx_version 'cerulean'
game 'gta5'

author 'Lucifer'
description 'Aktienmarkt System'
version '1.0.0'

dependency 'es_extended'
dependency 'mysql-async'

-- Client Scripts
client_script 'shared/config.lua'
client_script 'client/main.lua'

-- Server Scripts
server_script 'shared/config.lua'
server_script 'server/main.lua'

-- HTML
ui_page 'html/index.html'
files {
    'html/index.html',
    'html/stockmarket.js',
    'html/style.css',
    'html/script.js'
}
