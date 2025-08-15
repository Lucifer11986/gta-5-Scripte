local isPowerOutageActive = false
local icyRoadsActive = false
local blizzardBlips = {}
local bushfireBlip = nil
local originalGrip = {}

-- HILFSFUNKTIONEN
local function setVehicleGrip(vehicle, multiplier)
    local vehicleHash = GetEntityModel(vehicle)
    if not originalGrip[vehicleHash] then
        originalGrip[vehicleHash] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax')
    end
    local newGrip = originalGrip[vehicleHash] * multiplier
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', newGrip)
end

-- EVENT HANDLER
RegisterNetEvent("dynamic_events:powerOutage", function(coords, radius)
    SetArtificialLightsState(true)
    isPowerOutageActive = true
end)

RegisterNetEvent("dynamic_events:powerRestored", function()
    SetArtificialLightsState(false)
    isPowerOutageActive = false
end)

RegisterNetEvent("dynamic_events:blizzardWarning", function(blockedRoads)
    for _, road in ipairs(blockedRoads) do
        local blip = AddBlipForCoord(road.coords)
        SetBlipSprite(blip, 161)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Straßensperrung: " .. road.name)
        EndTextCommandSetBlipName(blip)
        table.insert(blizzardBlips, blip)
    end
end)

RegisterNetEvent("dynamic_events:blizzardEnd", function()
    for _, blip in ipairs(blizzardBlips) do
        RemoveBlip(blip)
    end
    blizzardBlips = {}
end)

RegisterNetEvent("dynamic_events:addBushfireBlip", function(x, y, z)
    if bushfireBlip and DoesBlipExist(bushfireBlip) then
        RemoveBlip(bushfireBlip)
    end
    bushfireBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(bushfireBlip, 436) -- Fire icon
    SetBlipColour(bushfireBlip, 1)   -- Red
    SetBlipScale(bushfireBlip, 1.5)
    SetBlipAsShortRange(bushfireBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Buschfeuer")
    EndTextCommandSetBlipName(bushfireBlip)
end)

RegisterNetEvent("dynamic_events:removeBushfireBlip", function()
    if bushfireBlip and DoesBlipExist(bushfireBlip) then
        RemoveBlip(bushfireBlip)
    end
    bushfireBlip = nil
end)

RegisterNetEvent("dynamic_events:icyRoadsStart", function()
    icyRoadsActive = true
end)

RegisterNetEvent("dynamic_events:icyRoadsEnd", function()
    icyRoadsActive = false
    -- Restore grip for all vehicles that were modified
    for vehicleHash, grip in pairs(originalGrip) do
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            if GetEntityModel(vehicle) == vehicleHash then
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', grip)
            end
        end
    end
    originalGrip = {}
end)

-- THREADS
Citizen.CreateThread(function()
    while true do
        Wait(500)
        if icyRoadsActive then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                setVehicleGrip(vehicle, Config.DynamicEvents.Glatteis.GripReduction)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetArtificialLightsState(false)
        TriggerEvent("dynamic_events:icyRoadsEnd") -- Restore grip on resource stop
    end
end)
