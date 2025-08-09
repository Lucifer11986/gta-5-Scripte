fx_version 'cerulean'
games { 'gta5' }

lua54 'yes'

author 'Lucifer | Awaria Modding'
description 'Advanced Elevator System'
version '2.0.0'

client_scripts {
    'client.lua'
}

server_scripts {
    -- Add server-related scripts here if necessary
}

shared_scripts {
    'config.lua'
}

escrow_ignore {
    'config.lua' -- Diese Datei bleibt editierbar
}
