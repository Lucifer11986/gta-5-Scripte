fx_version 'cerulean'
game 'gta5'

author 'AbyssForge Studio'
description 'AbyssForge Hud'
version '1.2' -- Or a relevant version

lua54 'yes'

shared_script '@es_extended/imports.lua'

client_scripts {
    'client/hud.lua'
}

server_scripts {
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

escrow_ignore {
    'fxmanifest.lua'
}

dependencies {
    'es_extended'
}

dependency '/assetpacks'