fx_version 'cerulean'
game 'gta5'

author 'Jules'
description 'A working stock market script'
version '1.1.0'

dependency 'es_extended'
dependency 'oxmysql'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'shared/config.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/config.lua',
    'server/main.lua'
}

sql_files {
    'install.sql'
}
