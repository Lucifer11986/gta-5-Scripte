local isPowerOutageActive = false
local blizzardBlips = {}

-- Stromausfall-Event
RegisterNetEvent("dynamic_events:powerOutage")
AddEventHandler("dynamic_events:powerOutage", function(coords, radius)
    -- This is a native that doesn't exist in default FiveM.
    -- It's a common custom native in some frameworks, but might not work here.
    -- A more compatible way would be to loop through streetlights and disable them,
    -- but that's much more complex. We'll use this as a placeholder.
    -- For testing, we'll just set the artificial lights state globally.
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

-- Ensure lights are on when the script stops/restarts
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetArtificialLightsState(false)
    end
end)
