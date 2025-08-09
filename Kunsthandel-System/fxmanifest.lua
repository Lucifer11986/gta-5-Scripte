-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

lua54 'yes'

description 'Kunsthandel-System '

author 'Lucifer'
version '2.1.0'

shared_script '@es_extended/imports.lua' -- Für ESX
shared_script '@qb-core/import.lua' -- Für QB-Core

server_scripts {
    'server/server.lua',
    'server/art_trade.lua'
}

client_scripts {
    'client/client.lua',
    'client/art_market.lua'
}

dependencies {
    'es_extended',
    --'qb-core'
}