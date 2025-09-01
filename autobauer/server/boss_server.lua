-- boss_server.lua

ESX = ESX or nil

-- Callback & Events erst nach ESX-Initialisierung registrieren
local function RegisterBossCallbacks()
    -- Mitarbeiter abrufen
    ESX.RegisterServerCallback('autobauer:server:getEmployees', function(source, cb)
        ExecuteQuery("SELECT * FROM job_employees", {}, function(result)
            cb(result)
        end)
    end)

    -- Mitarbeiter hinzufügen
    RegisterNetEvent('autobauer:server:addEmployee', function(citizenid, rank)
        ExecuteQuery("INSERT INTO job_employees (citizenid, job_rank, active) VALUES (?, ?, 1)", {citizenid, rank})
    end)

    -- Mitarbeiter entfernen
    RegisterNetEvent('autobauer:server:removeEmployee', function(citizenid)
        ExecuteQuery("DELETE FROM job_employees WHERE citizenid = ?", {citizenid})
    end)
end

-- Framework Detection für ESX
if Config.Framework == "ESX" then
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
        print("^2[Autobauer]^0 Boss-Script: ESX geladen!")
        RegisterBossCallbacks()
    end)
elseif Config.Framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
    print("^2[Autobauer]^0 Boss-Script: QBCore geladen!")
    -- QBCore-Version hier registrieren, falls benötigt
end
