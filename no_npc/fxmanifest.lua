fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Dynamic No NPC'
version '1.5.0'

client_scripts {
    'config.lua', -- Hinzufügen der config.lua
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

-- Escrow Protection
lua54 'yes'