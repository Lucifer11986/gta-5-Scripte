fx_version 'cerulean'
game 'gta5'

author 'AbyssForge Studio' -- Author changed
description 'Awaria Hud - Simple Variant' -- Description updated
version '1.3' -- Version bumped

lua54 'yes'

shared_script '@es_extended/imports.lua'

client_scripts {
    '@es_extended/locale.lua',
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

-- The main script files are protected by default.
-- Only list files here that should NOT be protected.
escrow_ignore {
    'fxmanifest.lua'
}

dependencies {
    'es_extended'
}

dependency '/assetpacks'
