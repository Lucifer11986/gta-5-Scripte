-- server/server.lua
ESX = nil
QBCore = nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    else
        print('Kein Framework erkannt!')
    end
end)

-- Beispiel-Event für den Server
RegisterNetEvent('art_trade:example')
AddEventHandler('art_trade:example', function()
    local xPlayer = ESX and ESX.GetPlayerFromId(source) or QBCore.Functions.GetPlayer(source)
    if xPlayer then
        print('Spieler gefunden:', xPlayer.identifier)
    end
end)