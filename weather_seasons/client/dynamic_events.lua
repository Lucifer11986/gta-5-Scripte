local isPowerOutageActive = false
local blizzardBlips = {}

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
        SetBlipSprite(blip, 161) -- Warning icon
        SetBlipColour(blip, 1) -- Red
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

local bushfireBlip = nil

-- Buschfeuer-Event
RegisterNetEvent("dynamic_events:bushfire")
AddEventHandler("dynamic_events:bushfire", function(location)
    -- Entferne alten Blip, falls vorhanden
    if bushfireBlip and DoesBlipExist(bushfireBlip) then
        RemoveBlip(bushfireBlip)
    end

    -- Erstelle neuen Blip
    bushfireBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(bushfireBlip, 436) -- Fire icon
    SetBlipColour(bushfireBlip, 1)   -- Red
    SetBlipScale(bushfireBlip, 1.5)
    SetBlipAsShortRange(bushfireBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Buschfeuer")
    EndTextCommandSetBlipName(bushfireBlip)
end)

RegisterNetEvent("dynamic_events:bushfireEnd")
AddEventHandler("dynamic_events:bushfireEnd", function()
    if bushfireBlip and DoesBlipExist(bushfireBlip) then
        RemoveBlip(bushfireBlip)
    end
    bushfireBlip = nil
end)

-- Ensure lights are on when the script stops/restarts
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetArtificialLightsState(false)
    end
end)
