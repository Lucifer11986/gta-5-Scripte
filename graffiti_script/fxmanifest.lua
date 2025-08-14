fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding - Modified by Jules'
description 'Graffiti-Script'
version '1.1.0'

-- Define the NUI page
ui_page 'html/index.html'

-- Files to be sent to the client
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'client/graffiti.lua',
    'client/spray_techniken.lua',
    'client/blackmarket.lua',
    'client/shop.lua',
    'client/cleanup.lua',
    'client/spray_ui.lua' -- Added UI script
}

server_scripts {
    'server/server.lua',
    'server/graffiti_management.lua',
    'server/spray_management.lua',
    'server/blackmarket.lua',
    'server/shop_server.lua',
    'server/cleanup_server.lua',
    'server/items.lua' -- Added usable items script
}
