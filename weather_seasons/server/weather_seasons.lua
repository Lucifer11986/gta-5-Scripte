ESX = exports["es_extended"]:getSharedObject()

local currentSeasonIndex = 1
local initialSeasonData = Config.Seasons[currentSeasonIndex]
local currentTemperature = math.random(initialSeasonData.min_temp, initialSeasonData.max_temp)
local currentWeather = "Clear"

function GetCurrentSeason()
    return Config.Seasons[currentSeasonIndex].name
end

function GetCurrentTemperature()
    return currentTemperature
end

function GetCurrentWeather()
    return currentWeather
end

function GetSeasonIndex(seasonName)
    for i, s in ipairs(Config.Seasons) do
        if s.name == seasonName then
            return i
        end
    end
    return 1 -- Default to Spring if not found
end

function SaveSeasonAndTemperature(season, temperature)
    MySQL.Async.execute("INSERT INTO server_settings (current_season, current_temperature) VALUES (?, ?)", {season, temperature})
end

function LoadSeasonAndTemperature()
    MySQL.Async.fetchAll("SELECT current_season, current_temperature FROM server_settings ORDER BY id DESC LIMIT 1", {}, function(result)
        if result and result[1] then
            local savedSeason = result[1].current_season
            local savedTemperature = result[1].current_temperature
            currentSeasonIndex = GetSeasonIndex(savedSeason)
            currentTemperature = savedTemperature
            print("[Weather Seasons] Geladene Jahreszeit: " .. savedSeason)
        else
            -- No season in DB, start with the first one
            local seasonData = Config.Seasons[currentSeasonIndex]
            currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
            print("[Weather Seasons] Keine gespeicherte Jahreszeit gefunden, starte mit: " .. seasonData.name)
            SaveSeasonAndTemperature(seasonData.name, currentTemperature)
        end
        -- Signal that the system is ready
        TriggerEvent("weather_seasons:initialized")
        -- Update clients with the correct initial state
        TriggerClientEvent("season:updateSeason", -1, GetCurrentSeason(), currentTemperature)
        TriggerClientEvent("season:notifySeasonChange", -1, GetCurrentSeason())
    end)
end

function ChangeSeason()
    currentSeasonIndex = currentSeasonIndex + 1
    if currentSeasonIndex > #Config.Seasons then
        currentSeasonIndex = 1
    end

    local seasonData = Config.Seasons[currentSeasonIndex]
    currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
    local seasonName = seasonData.name

    TriggerClientEvent("season:updateSeason", -1, seasonName, currentTemperature)
    TriggerClientEvent("season:notifySeasonChange", -1, seasonName)
    SaveSeasonAndTemperature(seasonName, currentTemperature)
end

-- Main timer loop for season changes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.SeasonDuration * 1000)
        ChangeSeason()
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Wait a moment for MySQL to be ready
        Citizen.Wait(1000)
        LoadSeasonAndTemperature()
    end
end)

RegisterNetEvent("weather:setWeather")
AddEventHandler("weather:setWeather", function(weatherType)
    currentWeather = weatherType
    TriggerClientEvent("weather:updateWeather", -1, weatherType)
end)

-- Exports for other server scripts
exports("GetCurrentSeason", GetCurrentSeason)
exports("GetCurrentTemperature", GetCurrentTemperature)
exports("GetCurrentWeather", GetCurrentWeather)
exports("IsHeatwaveActive", function()
    return GetCurrentTemperature() >= Config.HeatwaveTemperature
end)
