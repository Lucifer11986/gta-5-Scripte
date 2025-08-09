fx_version 'cerulean'
game 'gta5'

author 'Lucifer | Awaria Modding'
description 'Drogenabhängigkeits-System'
version '1.1.0'

shared_script 'config.lua'

client_scripts {
    'client/client.lua',
    'client/drugs.lua',
    'client/withdrawal.lua',
    'client/drug_trade.lua',
    'client/effects.lua',
    'client/medic_use.lua',
    'client/events.lua',
    'client/medic.lua',
    'client/rehab.lua',
    'client/shop.lua',
    'client/sleep.lua',
    'client/sleep_effects.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Für Datenbank-Support (async optional)
    'server/server.lua',
    'server/transactions.lua',
    'server/rehab.lua',
    'server/shop.lua',
    'server/rewards.lua',
    'server/medic.lua',
    'server/events.lua',
    'server/drug_trade.lua',
    'server/database.lua',
    'server/addiction.lua'
}
