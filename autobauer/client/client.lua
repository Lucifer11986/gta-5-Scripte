ESX, QBCore = nil, nil
local PlayerData = {}
local hasFactoryJob = false

-- =====================
-- Framework Detection
-- =====================
Citizen.CreateThread(function()
    if Config.Framework == "ESX" then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(50)
        end
        print("^2[Autobauer]^0 Client: ESX geladen!")

        -- Handle race condition where player is already loaded
        if ESX.IsPlayerLoaded() then
            PlayerData = ESX.GetPlayerData()
            UpdateJobStatus()
        end

    elseif Config.Framework == "QBCore" then
        QBCore = exports['qb-core']:GetCoreObject()
        print("^2[Autobauer]^0 Client: QBCore geladen!")

        -- Handle race condition for QBCore
        if QBCore.Functions.GetPlayerData() then
            PlayerData = QBCore.Functions.GetPlayerData()
            UpdateJobStatus()
        end
    end
end)

-- =====================
-- Framework Events
-- =====================
if Config.Framework == "ESX" then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        UpdateJobStatus()
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
        UpdateJobStatus()
    end)
elseif Config.Framework == "QBCore" then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
        UpdateJobStatus()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
        PlayerData.job = job
        UpdateJobStatus()
    end)
end

-- =====================
-- Job-Check Funktion
-- =====================
function UpdateJobStatus()
    if PlayerData and PlayerData.job then
        local jobName = PlayerData.job.name
        local jobLabel = PlayerData.job.label

        -- Check both job name and label against the allowed list for robustness
        hasFactoryJob = (Config.AllowedFactoryJobs[jobName] or Config.AllowedFactoryJobs[jobLabel]) or false
    else
        hasFactoryJob = false
    end
end

-- =====================
-- Blip + Marker + Menü Trigger
-- =====================
local blipCoords = vector3(768.6292, -1643.2709, 30.1057)
CreateThread(function()
    local blip = AddBlipForCoord(blipCoords)
    SetBlipSprite(blip, 225)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Autobauer Werkstatt")
    EndTextCommandSetBlipName(blip)

    while true do
        Wait(0)
        if hasFactoryJob then
            local coords = GetEntityCoords(PlayerPedId())
            local dist = #(coords - blipCoords)

            if dist < 5.0 then
                DrawMarker(2, blipCoords.x, blipCoords.y, blipCoords.z - 0.5, 0,0,0,0,0,0,1.0,1.0,0.5,255,165,0,100,0,0,0,0)
                if dist < 1.5 and IsControlJustReleased(0, 38) then
                    OpenBossMenu()
                end
            end
        end
    end
end)

-- =====================
-- Funktion zum Öffnen des Boss Menüs
-- =====================
function OpenBossMenu()
    if not hasFactoryJob then
        if ESX then ESX.ShowNotification("Du hast keinen Zugriff auf das Boss Menü!") end
        return
    end

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SEAT_WALL_TABLET", 0, true)

    -- NUI öffnen
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openBossMenu" })

    -- Fahrzeuge vom Server laden
    if ESX then
        ESX.TriggerServerCallback('autobauer:server:getVehicles', function(vehicles)
            SendNUIMessage({ action = "setVehicles", vehicles = vehicles })
        end)
    elseif QBCore then
        QBCore.Functions.TriggerCallback('autobauer:server:getVehicles', function(vehicles)
            SendNUIMessage({ action = "setVehicles", vehicles = vehicles })
        end)
    end
end

-- =====================
-- NUI Callbacks
-- =====================
RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    cb('ok')
end)

RegisterNUICallback('startProduction', function(data, cb)
    if hasFactoryJob then
        TriggerServerEvent('autobauer:server:startProduction', data.vehicleName, data.customPrice)
    else
        if ESX then ESX.ShowNotification("Du kannst keine Produktion starten!") end
    end
    cb('ok')
end)

RegisterNUICallback('sendToDealership', function(data, cb)
    if hasFactoryJob then
        TriggerServerEvent('autobauer:server:sendToDealership', data.carId)
    else
        if ESX then ESX.ShowNotification("Du kannst keine Fahrzeuge verschieben!") end
    end
    cb('ok')
end)

-- =====================
-- Server Events aktualisieren NUI
-- =====================
RegisterNetEvent('autobauer:client:updateProductionQueue')
AddEventHandler('autobauer:client:updateProductionQueue', function(queue)
    SendNUIMessage({ action = "updateProductionQueue", queue = queue })
end)

RegisterNetEvent('autobauer:client:updateVehicleStorage')
AddEventHandler('autobauer:client:updateVehicleStorage', function(storage)
    SendNUIMessage({ action = "updateVehicleStorage", storage = storage })
end)

RegisterNetEvent('autobauer:client:updateSocietyMoney')
AddEventHandler('autobauer:client:updateSocietyMoney', function(money)
    SendNUIMessage({ action = "updateSocietyMoney", money = money })
end)

RegisterNetEvent('autobauer:client:loadEmployees')
AddEventHandler('autobauer:client:loadEmployees', function(employees)
    SendNUIMessage({ action = "loadEmployees", employees = employees })
end)

RegisterNetEvent('autobauer:client:loadMaterials')
AddEventHandler('autobauer:client:loadMaterials', function(materials)
    SendNUIMessage({ action = "loadMaterials", materials = materials })
end)

RegisterNetEvent('autobauer:client:loadGrades')
AddEventHandler('autobauer:client:loadGrades', function(grades)
    SendNUIMessage({ action = "loadGrades", grades = grades })
end)

RegisterNetEvent('autobauer:client:loadOrders')
AddEventHandler('autobauer:client:loadOrders', function(orders)
    SendNUIMessage({ action = "loadOrders", orders = orders })
end)
