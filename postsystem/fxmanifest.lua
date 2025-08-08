fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Postsystem'
version '1.5.0'

lua54 'yes' -- Erforderlich für Escrow Protection

escrow_ignore {
    'config.lua', -- Konfigurationsdatei für Anpassungen
    'html/*' -- UI-Dateien sollten nicht verschlüsselt sein
}

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/ui.lua',
    'client/postman.lua', -- Neue Datei für den Postboten-Job
    'client/mailbox.lua' -- Neue Datei für Briefkästen
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- MySQL-Bibliothek
    'server/main.lua',
    'server/postman.lua', -- Neue Datei für den Postboten-Job
    'server/mailbox.lua', -- Neue Datei für Briefkästen
    'config.lua'
}

ui_page 'html/ui.html' -- Stellt sicher, dass die UI-Datei geladen wird

files {
    'html/ui.html',
    'html/ui.css',
    'html/ui.js',
    'html/locker.html',
    'html/locker.js',
    'html/images/post_logo.png'
}