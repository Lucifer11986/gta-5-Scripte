-- boss.lua
ESX = nil

-- =====================
-- Framework Detection (ESX)
-- =====================
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(50)
    end
    print("^2[Autobauer]^0 Boss: ESX geladen!")
end)

-- =====================
-- Mitarbeiterliste abrufen
-- =====================
RegisterNetEvent('autobauer:client:refreshEmployees')
AddEventHandler('autobauer:client:refreshEmployees', function()
    if ESX then
        ESX.TriggerServerCallback('autobauer:server:getEmployees', function(employees)
            SendNUIMessage({ action = "updateEmployees", employees = employees })
        end)
    end
end)

-- =====================
-- NUI Callbacks für Mitarbeiterverwaltung
-- =====================
RegisterNUICallback('addEmployee', function(data, cb)
    if data.citizenid and data.rank then
        TriggerServerEvent('autobauer:server:addEmployee', data.citizenid, data.rank)
    end
    cb('ok')
end)

RegisterNUICallback('removeEmployee', function(data, cb)
    if data.citizenid then
        TriggerServerEvent('autobauer:server:removeEmployee', data.citizenid)
    end
    cb('ok')
end)
