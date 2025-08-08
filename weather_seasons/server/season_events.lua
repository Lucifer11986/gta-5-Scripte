ESX = exports["es_extended"]:getSharedObject()

local currentSeasonIndex = 1
local currentTemperature = 15
local seasons = {}

-- Fülle die `seasons` Tabelle dynamisch aus der Konfiguration
for i, seasonData in ipairs(Config.Seasons) do
    seasons[i] = seasonData.name
end

-- Hilfsfunktion, um die Temperaturdaten für eine Jahreszeit aus der Config zu holen
function GetSeasonTempData(seasonName)
    for _, seasonData in ipairs(Config.Seasons) do
        if seasonData.name == seasonName then
            return seasonData
        end
    end
    return nil
end

-- **API, um die aktuelle Jahreszeit abzurufen**
RegisterNetEvent("season:getSeasonInfo")
AddEventHandler("season:getSeasonInfo", function(source)
    TriggerClientEvent("season:returnSeasonInfo", source, GetCurrentSeason(), GetCurrentTemperature())
end)

-- **API, um die Temperatur zu überprüfen**
RegisterNetEvent("season:getTemperature")
AddEventHandler("season:getTemperature", function(source)
    TriggerClientEvent("season:returnTemperature", source, GetCurrentTemperature())
end)

-- **API, um die Jahreszeit zu ändern**
RegisterNetEvent("season:setSeason")
AddEventHandler("season:setSeason", function(seasonName)
    local seasonData = GetSeasonTempData(seasonName)
    if seasonData then
        currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
        currentSeasonIndex = GetSeasonIndex(seasonName)
        SaveSeasonAndTemperature(seasonName, currentTemperature)
        TriggerClientEvent("season_events:updateSeason", -1, seasonName, currentTemperature)
    else
        print("Ungültige Jahreszeit.")
    end
end)

function GetCurrentSeason()
    return seasons[currentSeasonIndex]
end

function GetCurrentTemperature()
    return currentTemperature
end

function UpdateTemperature(season)
    local seasonData = GetSeasonTempData(season)
    if seasonData then
        currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
    end
end

function GetSeasonIndex(season)
    for i, s in ipairs(seasons) do
        if s == season then
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

            TriggerClientEvent("season_events:updateSeason", -1, savedSeason, savedTemperature)
        else
            -- Falls keine gespeicherten Werte existieren, setze die Jahreszeit auf Frühling
            currentSeasonIndex = 1
            local seasonData = GetSeasonTempData("Frühling")
            if seasonData then
                currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
            end
            SaveSeasonAndTemperature("Frühling", currentTemperature)
            TriggerClientEvent("season_events:updateSeason", -1, "Frühling", currentTemperature)
        end
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadSeasonAndTemperature()
    end
end)

-- **Berechnung der Jahreszeit basierend auf dem aktuellen Datum**
function GetSeasonFromDate()
    local currentMonth = GetCurrentMonth()  -- Monat (1 bis 12)
    if currentMonth >= 3 and currentMonth <= 5 then
        return "Frühling"
    elseif currentMonth >= 6 and currentMonth <= 8 then
        return "Sommer"
    elseif currentMonth >= 9 and currentMonth <= 11 then
        return "Herbst"
    else
        return "Winter"
    end
end

-- Funktion, die den aktuellen Monat zurückgibt
function GetCurrentMonth()
    return tonumber(os.date("%m"))
end

-- **Berechnung der Temperatur basierend auf der Jahreszeit**
function UpdateSeasonAndTemperatureBasedOnDate()
    local currentSeason = GetSeasonFromDate()
    currentSeasonIndex = GetSeasonIndex(currentSeason)
    UpdateTemperature(currentSeason)
    SaveSeasonAndTemperature(currentSeason, currentTemperature)
    TriggerClientEvent("season_events:updateSeason", -1, currentSeason, currentTemperature)
end

-- Update der Jahreszeit und Temperatur alle 30 Minuten
CreateThread(function()
    while true do
        Wait(1800000)  -- 30 Minuten
        UpdateSeasonAndTemperatureBasedOnDate()
    end
end)

function IsHeatwaveActive()
    return currentTemperature and currentTemperature >= Config.HeatwaveTemperature
end

function IsPlayerAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.getGroup() == "admin"
end

RegisterCommand("setseason", function(source, args)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, { args = { "[SEASON]", "❌ Du hast keine Berechtigung, die Jahreszeit zu ändern!" } })
        return
    end

    if args[1] then
        local newSeason = args[1]:gsub("^%s*(.-)%s*$", "%1")  -- Trimmen der Leerzeichen
        local seasonData = GetSeasonTempData(newSeason)
        if seasonData then
            currentSeasonIndex = GetSeasonIndex(newSeason)
            UpdateTemperature(newSeason)
            SaveSeasonAndTemperature(newSeason, currentTemperature)
            TriggerClientEvent("season_events:updateSeason", -1, newSeason, currentTemperature)
            TriggerClientEvent('chat:addMessage', source, { args = { "[SEASON]", "✅ Jahreszeit auf " .. newSeason .. " gesetzt!" } })
        else
            TriggerClientEvent('chat:addMessage', source, { args = { "[SEASON]", "❌ Ungültige Jahreszeit." } })
        end
    end
end, false)
