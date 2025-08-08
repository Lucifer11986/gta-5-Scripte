ESX = exports["es_extended"]:getSharedObject()

-- Lade die Config-Datei
local configContent = LoadResourceFile(GetCurrentResourceName(), "config.lua")
if configContent then
    local env = {}
    local func, err = load(configContent, "config.lua", "t", env)
    if func then
        local success, loadErr = pcall(func)
        if success then
            Config = env.Config
        end
    end
end

local currentSeasonIndex = 1
local currentTemperature = Config.Seasons[currentSeasonIndex].temperature
local currentWeather = "Clear" -- Standardwert für das Wetter

function GetCurrentSeason()
    return Config.Seasons[currentSeasonIndex].name
end

function GetCurrentTemperature()
    return currentTemperature
end

function GetCurrentWeather()
    return currentWeather
end

function GetSeasonIndex(season)
    for i, s in ipairs(Config.Seasons) do
        if s.name == season then
            return i
        end
    end
    return 1
end

function SaveSeasonAndTemperature(season, temperature)
    local query = "INSERT INTO server_settings (current_season, current_temperature) VALUES (?, ?)"
    MySQL.Async.execute(query, {season, temperature})
end

function LoadSeasonAndTemperature()
    MySQL.Async.fetchAll("SELECT current_season, current_temperature FROM server_settings ORDER BY id DESC LIMIT 1", {}, function(result)
        if result[1] then
            local savedSeason = result[1].current_season
            local savedTemperature = result[1].current_temperature

            currentSeasonIndex = GetSeasonIndex(savedSeason)
            currentTemperature = savedTemperature

            TriggerClientEvent("season:updateSeason", -1, savedSeason, savedTemperature)
        end
    end)
end

local function ChangeSeason()
    currentSeasonIndex = currentSeasonIndex + 1
    if currentSeasonIndex > #Config.Seasons then
        currentSeasonIndex = 1
    end

    currentTemperature = Config.Seasons[currentSeasonIndex].temperature
    local seasonName = Config.Seasons[currentSeasonIndex].name

    TriggerClientEvent("season:updateSeason", -1, seasonName, currentTemperature)
    TriggerClientEvent("season:notifySeasonChange", -1, seasonName)

    SaveSeasonAndTemperature(seasonName, currentTemperature)
end

ChangeSeason()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.SeasonDuration * 1000)
        ChangeSeason()
    end
end)

RegisterNetEvent("season:getCurrentSeason")
AddEventHandler("season:getCurrentSeason", function()
    local src = source
    TriggerClientEvent("season:updateSeason", src, Config.Seasons[currentSeasonIndex].name, currentTemperature)
end)

RegisterNetEvent("weather:setWeather")
AddEventHandler("weather:setWeather", function(weatherType)
    currentWeather = weatherType
    TriggerClientEvent("weather:updateWeather", -1, weatherType)
end)

RegisterNetEvent("weather:getWeather")
AddEventHandler("weather:getWeather", function()
    local src = source
    TriggerClientEvent("weather:updateWeather", src, currentWeather)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadSeasonAndTemperature()
    end
end)

function IsHeatwaveActive()
    local currentTemp = GetCurrentTemperature()
    return currentTemp and currentTemp >= Config.HeatwaveTemperature
end

ESX.RegisterServerCallback("weather:getTemperature", function(source, cb)
    cb(GetCurrentTemperature())
end)
