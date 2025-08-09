fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Willkommensnachricht Script'
version '2.0.0'

lua54 'yes'

-- Escrow Protection
escrow_ignore {
    'config.lua'
}

-- Benötigte Dependencies
dependency 'oxmysql' -- Falls oxmysql benötigt wird (falls nicht, kannst du es entfernen)

-- Client und Server Scripts
shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

-- Dateien für Escrow Protection (bei Tebex-Verschlüsselung erforderlich)
files {
    'config.lua'
}

-- Escrow Protection aktivieren (nur wenn das Script verschlüsselt ist)
dependency '/assetpacks'
