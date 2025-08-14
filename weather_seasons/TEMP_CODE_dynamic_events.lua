local ESX = exports['es_extended']:getSharedObject()
local isEventActive = false
local icyRoadsActive = false

function ServerAnnouncement(msg, color)
    TriggerClientEvent('chat:addMessage', -1, {
        color = color or {255, 0, 0},
        multiline = true,
        args = {"Server", msg}
    })
    Citizen.SetTimeout(6000, function()
        TriggerClientEvent('chat:clear', -1)
    end)
end

function StartPowerOutage()
    isEventActive = true
    local eventConfig = Config.DynamicEvents.PowerOutage
    local location = eventConfig.Locations[math.random(#eventConfig.Locations)]
    local duration = math.random(eventConfig.DurationMinutes.min, eventConfig.DurationMinutes.max) * 60000

    ServerAnnouncement("Ein Gewitter hat einen Stromausfall in " .. location.name .. " verursacht!", {255, 255, 0})
    TriggerClientEvent("dynamic_events:powerOutage", -1, location.coords, location.radius)

    SetTimeout(duration, function()
        TriggerClientEvent("dynamic_events:powerRestored", -1)
        ServerAnnouncement("Der Strom in " .. location.name .. " wurde wiederhergestellt.", {0, 255, 0})
        isEventActive = false
    end)
end

-- KORRIGIERTE FUNKTION
function StartBushfire()
    isEventActive = true
    local eventConfig = Config.DynamicEvents.Bushfire
    local location = eventConfig.Locations[math.random(#eventConfig.Locations)]

    -- Ankündigung senden
    ServerAnnouncement("Ein Buschfeuer ist ausgebrochen! Die Feuerwehr wird alarmiert.", {255, 140, 0})

    -- Feuer vom Server starten
    StartScriptFire(location.x, location.y, location.z, 25, true)

    -- Blip-Erstellung an den Client senden
    TriggerClientEvent("dynamic_events:addBushfireBlip", -1, location.x, location.y, location.z)

    SetTimeout(10 * 60000, function()
        -- Feuer vom Server löschen
        StopFireInRange(location.x, location.y, location.z, 50.0)

        -- Blip-Entfernung an den Client senden
        TriggerClientEvent("dynamic_events:removeBushfireBlip", -1)
        isEventActive = false
    end)
end

function StartBlizzard()
    isEventActive = true
    local eventConfig = Config.DynamicEvents.Blizzard
    ServerAnnouncement("Ein Schneesturm führt zu Straßensperrungen!", {173, 216, 230})
    TriggerClientEvent("dynamic_events:blizzardWarning", -1, eventConfig.BlockedRoads)
    SetTimeout(10 * 60000, function()
        TriggerClientEvent("dynamic_events:blizzardEnd", -1)
        isEventActive = false
    end)
end

function StartIcyRoads()
    icyRoadsActive = true
    local duration = math.random(5, 30) * 60000 -- 5 bis 30 Minuten

    ServerAnnouncement("~b~Achtung: Glatteis auf den Straßen! Fahr vorsichtig!", {0, 191, 255})
    TriggerClientEvent("dynamic_events:icyRoadsStart", -1)

    Citizen.CreateThread(function()
        local remaining = duration / 1000
        while remaining > 0 and icyRoadsActive do
            Citizen.Wait(1000)
            remaining = remaining - 1
            if exports.weather_seasons:GetCurrentTemperature() >= 0 then
                break
            end
        end
        if icyRoadsActive then
            icyRoadsActive = false
            TriggerClientEvent("dynamic_events:icyRoadsEnd", -1)
            ServerAnnouncement("~g~Das Glatteis ist verschwunden.", {0, 255, 0})
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.DynamicEvents.CheckIntervalMinutes * 60 * 1000)

        if not isEventActive and not icyRoadsActive then
            local weather = exports.weather_seasons:GetCurrentWeather()
            local temp = exports.weather_seasons:GetCurrentTemperature()
            local isHeatwave = exports.weather_seasons:IsHeatwaveActive()

            if weather == "THUNDER" and math.random() < Config.DynamicEvents.PowerOutage.Chance then
                StartPowerOutage()
            elseif isHeatwave and math.random() < Config.DynamicEvents.Bushfire.Chance then
                StartBushfire()
            elseif weather == "BLIZZARD" and math.random() < Config.DynamicEvents.Blizzard.Chance then
                StartBlizzard()
            elseif temp < 0 and math.random() < Config.DynamicEvents.Glatteis.Chance then
                StartIcyRoads()
            end
        end

        if icyRoadsActive and exports.weather_seasons:GetCurrentTemperature() >= 0 then
            icyRoadsActive = false
            TriggerClientEvent("dynamic_events:icyRoadsEnd", -1)
            ServerAnnouncement("~g~Das Glatteis wurde durch steigende Temperaturen beseitigt.", {0, 255, 0})
        end
    end
end)
