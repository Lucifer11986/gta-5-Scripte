--[[
    Dieses Skript stellt Wrapper-Funktionen zur Verfügung,
    um die Kompatibilität zwischen ESX und QBCore zu gewährleisten.
]]

-- Globale Framework-Objekte (werden auf dem jeweiligen Scope, Server oder Client, gesetzt)
ESX = nil
QBCore = nil

CreateThread(function()
    if Config.Framework == 'esx' then
        if IsDuplicityVersion() then -- Server-side
            ESX = exports['es_extended']:getSharedObject()
        else -- Client-side
            CreateThread(function()
                while ESX == nil do
                    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                    Wait(100)
                end
            end)
        end
    elseif Config.Framework == 'qb' then
        if IsDuplicityVersion() then -- Server-side
            QBCore = exports['qb-core']:GetCoreObject()
        else -- Client-side
            QBCore = exports['qb-core']:GetCoreObject()
        end
    else
        print('FEHLER: Ungültiges Framework in config.lua angegeben!')
    end
end)

-- Wrapper für Benachrichtigungen
if IsDuplicityVersion() then -- SERVER-SIDE
    function ShowNotification(source, message)
        if Config.Framework == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
        elseif Config.Framework == 'qb' then
            TriggerClientEvent('QBCore:Notify', source, message)
        end
    end
else -- CLIENT-SIDE
    function ShowNotification(message)
        if Config.Framework == 'esx' then
            ESX.ShowNotification(message)
        elseif Config.Framework == 'qb' then
            QBCore.Functions.Notify(message)
        end
    end
end


-- Wrapper, um das Spieler-Objekt abzurufen (nur Server)
function GetPlayer(source)
    if not IsDuplicityVersion() then return nil end -- Nur auf dem Server ausführen

    if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    end
    return nil
end
