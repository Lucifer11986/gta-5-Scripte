ESX = exports['es_extended']:getSharedObject()

local isPowerOutageActive = false
local blizzardBlips = {}
local bushfireFires = {}
local isIcyRoadsActive = false
local bushfireBlip = nil

-- Stromausfall-Event
RegisterNetEvent("dynamic_events:powerOutage")
AddEventHandler("dynamic_events:powerOutage", function(coords, radius)
    SetArtificialLightsState(true)
    isPowerOutageActive = true
end)

RegisterNetEvent("dynamic_events:powerRestored")
AddEventHandler("dynamic_events:powerRestored", function()
    SetArtificialLightsState(false)
    isPowerOutageActive = false
end)

-- Blizzard-Event
RegisterNetEvent("dynamic_events:blizzardWarning")
AddEventHandler("dynamic_events:blizzardWarning", function(blockedRoads)
    for _, road in ipairs(blockedRoads) do
        local blip = AddBlipForCoord(road.coords)
        SetBlipSprite(blip, 161) -- Warnungssymbol
        SetBlipColour(blip, 1) -- Rot
        SetBlipScale(blip, 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Straßensperrung: " .. road.name)
        EndTextCommandSetBlipName(blip)
        table.insert(blizzardBlips, blip)
    end
end)

RegisterNetEvent("dynamic_events:blizzardEnd")
AddEventHandler("dynamic_events:blizzardEnd", function()
    for _, blip in ipairs(blizzardBlips) do
        RemoveBlip(blip)
    end
    blizzardBlips = {}
end)

-- Buschfeuer-Event starten
RegisterNetEvent("dynamic_events:startBushfireClient")
AddEventHandler("dynamic_events:startBushfireClient", function(x, y, z)
    local fireHandle = StartScriptFire(x, y, z, 25, true)
    table.insert(bushfireFires, fireHandle)
end)

-- Buschfeuer Blip hinzufügen
RegisterNetEvent("dynamic_events:addBushfireBlip")
AddEventHandler("dynamic_events:addBushfireBlip", function(x, y, z)
    if bushfireBlip then
        RemoveBlip(bushfireBlip)
    end
    bushfireBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(bushfireBlip, 436) -- Feuer-Icon
    SetBlipColour(bushfireBlip, 1)   -- Rot
    SetBlipScale(bushfireBlip, 1.2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Buschfeuer")
    EndTextCommandSetBlipName(bushfireBlip)
end)

-- Buschfeuer Blip entfernen
RegisterNetEvent("dynamic_events:removeBushfireBlip")
AddEventHandler("dynamic_events:removeBushfireBlip", function()
    if bushfireBlip then
        RemoveBlip(bushfireBlip)
        bushfireBlip = nil
    end
end)

-- Cleanup beim Resource Stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetArtificialLightsState(false)

        for _, fireHandle in ipairs(bushfireFires) do
            RemoveScriptFire(fireHandle)
        end
        bushfireFires = {}

        for _, blip in ipairs(blizzardBlips) do
            RemoveBlip(blip)
        end
        blizzardBlips = {}

        if bushfireBlip then
            RemoveBlip(bushfireBlip)
            bushfireBlip = nil
        end
    end
end)

-- Glatteis Events
RegisterNetEvent("dynamic_events:icyRoadsStart")
AddEventHandler("dynamic_events:icyRoadsStart", function()
    isIcyRoadsActive = true
    ESX.ShowNotification("~b~Glatteis auf den Straßen! Fahr vorsichtig!")
end)

RegisterNetEvent("dynamic_events:icyRoadsEnd")
AddEventHandler("dynamic_events:icyRoadsEnd", function()
    isIcyRoadsActive = false
    ESX.ShowNotification("~g~Das Glatteis ist verschwunden.")
end)

-- Beispiel: Fahrverhalten anpassen bei Glatteis (optional)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if isIcyRoadsActive then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", 1.0, true)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 0.8, true)
                SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 1.2, true)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)
