local isEventActive = false

function StartPowerOutage()
    isEventActive = true
    local eventConfig = Config.DynamicEvents.PowerOutage
    local location = eventConfig.Locations[math.random(#eventConfig.Locations)]
    local duration = math.random(eventConfig.DurationMinutes.min, eventConfig.DurationMinutes.max) * 60000

    TriggerClientEvent("esx:showNotification", -1, "Ein Gewitter hat einen Stromausfall in " .. location.name .. " verursacht!")
    TriggerClientEvent("dynamic_events:powerOutage", -1, location.coords, location.radius)

    SetTimeout(duration, function()
        TriggerClientEvent("dynamic_events:powerRestored", -1)
        TriggerClientEvent("esx:showNotification", -1, "Der Strom in " .. location.name .. " wurde wiederhergestellt.")
        isEventActive = false
    end)
end

function StartBushfire()
    isEventActive = true
    local eventConfig = Config.DynamicEvents.Bushfire
    local location = eventConfig.Locations[math.random(#eventConfig.Locations)]
    -- Korrekter Aufruf des Server-Natives
    StartScriptFire(location.x, location.y, location.z, 25, true)
    TriggerClientEvent("esx:showNotification", -1, "Ein Buschfeuer ist ausgebrochen! Die Feuerwehr wird alarmiert.")
    SetTimeout(10 * 60000, function() isEventActive = false end)
end

function StartBlizzard()
    isEventActive = true
    local eventConfig = Config.DynamicEvents.Blizzard
    TriggerClientEvent("esx:showNotification", -1, "Ein Schneesturm führt zu Straßensperrungen!")
    TriggerClientEvent("dynamic_events:blizzardWarning", -1, eventConfig.BlockedRoads)
    SetTimeout(10 * 60000, function()
        TriggerClientEvent("dynamic_events:blizzardEnd", -1)
        isEventActive = false
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.DynamicEvents.CheckIntervalMinutes * 60 * 1000)

        if not isEventActive then
            local weather = exports.weather_seasons:GetCurrentWeather()
            local isHeatwave = exports.weather_seasons:IsHeatwaveActive()

            if weather == "THUNDER" and math.random() < Config.DynamicEvents.PowerOutage.Chance then
                StartPowerOutage()
            elseif isHeatwave and math.random() < Config.DynamicEvents.Bushfire.Chance then
                StartBushfire()
            elseif weather == "BLIZZARD" and math.random() < Config.DynamicEvents.Blizzard.Chance then
                StartBlizzard()
            end
        end
    end
end)
