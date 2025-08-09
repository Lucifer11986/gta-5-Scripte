fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Graffiti-Script'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'client/graffiti.lua',
    'client/spray_techniken.lua',
    'client/blackmarket.lua',
    'client/shop.lua',
    'client/cleanup.lua'
}

server_scripts {
    'server/server.lua',
    'server/graffiti_management.lua',
    'server/spray_management.lua',
    'server/blackmarket.lua',
    'server/shop_server.lua',
    'server/cleanup_server.lua'
}
