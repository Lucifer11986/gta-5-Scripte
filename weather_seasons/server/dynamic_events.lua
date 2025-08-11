local ESX = exports['es_extended']:getSharedObject()
local isEventActive = false
local icyRoadsActive = false

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

    TriggerClientEvent("dynamic_events:startBushfireClient", -1, location.x, location.y, location.z)

    TriggerClientEvent("esx:showNotification", -1, "Ein Buschfeuer ist ausgebrochen! Die Feuerwehr wird alarmiert.")
    
    SetTimeout(10 * 60000, function()
        isEventActive = false
    end)
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

function StartIcyRoads()
    icyRoadsActive = true
    local duration = math.random(5, 30) * 60000 -- 5 bis 30 Minuten

    TriggerClientEvent("esx:showNotification", -1, "~b~Achtung: Glatteis auf den Straßen! Fahr vorsichtig!")
    TriggerClientEvent("dynamic_events:icyRoadsStart", -1)

    SetTimeout(duration, function()
        if icyRoadsActive then
            icyRoadsActive = false
            TriggerClientEvent("dynamic_events:icyRoadsEnd", -1)
            TriggerClientEvent("esx:showNotification", -1, "~g~Das Glatteis wurde wieder beseitigt.")
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.DynamicEvents.CheckIntervalMinutes * 60 * 1000)

        if not isEventActive and not icyRoadsActive then
            local weather = exports.weather_seasons:GetCurrentWeather()
            local temp = exports.weather_seasons.GetCurrentTemperature and exports.weather_seasons:GetCurrentTemperature() or 10
            local isHeatwave = exports.weather_seasons:IsHeatwaveActive()

            if weather == "THUNDER" and math.random() < Config.DynamicEvents.PowerOutage.Chance then
                StartPowerOutage()
            elseif isHeatwave and math.random() < Config.DynamicEvents.Bushfire.Chance then
                StartBushfire()
            elseif weather == "BLIZZARD" and math.random() < Config.DynamicEvents.Blizzard.Chance then
                StartBlizzard()
            elseif temp < 0 then
                if math.random() < 0.3 then -- 30% Chance, wenn Temperatur unter 0
                    StartIcyRoads()
                end
            end
        end

        -- Glatteis vorzeitig beenden, wenn Temperatur steigt
        if icyRoadsActive then
            local temp = exports.weather_seasons.GetCurrentTemperature and exports.weather_seasons:GetCurrentTemperature() or 10
            if temp >= 0 then
                icyRoadsActive = false
                TriggerClientEvent("dynamic_events:icyRoadsEnd", -1)
                TriggerClientEvent("esx:showNotification", -1, "~g~Das Glatteis wurde durch steigende Temperaturen beseitigt.")
            end
        end
    end
end)
