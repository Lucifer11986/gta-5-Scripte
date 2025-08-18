Citizen.CreateThread(function()
    -- Robustes Warten auf die Konfiguration, um Race Conditions zu vermeiden
    while Config == nil or Config.SeasonDurationSeconds == nil do
        print("[Weather Seasons] Warte auf Konfiguration...")
        Wait(500)
    end
    print("[Weather Seasons] Konfiguration geladen.")

    local currentSeasonIndex = 1
    local currentTemperature = 20
    local currentWeather = "CLEAR" -- Wetter-Variable hinzugefügt

    -- Wetter-Typen pro Jahreszeit
    local weatherForSeason = {
        ["Frühling"] = {"CLEAR", "EXTRASUNNY", "CLOUDS", "RAIN", "FOGGY"},
        ["Sommer"] = {"EXTRASUNNY", "CLEAR", "CLOUDS", "THUNDER"},
        ["Herbst"] = {"CLOUDS", "RAIN", "FOGGY", "THUNDER"},
        ["Winter"] = {"SNOW", "BLIZZARD", "CLOUDS", "FOGGY"}
    }

    -- Diese Funktion könnte erweitert werden, um den Zustand in einer DB zu speichern
    local function saveServerState()
        -- z.B. MySQL.Async.execute(...)
    end

    -- Diese Funktion könnte erweitert werden, um den Zustand aus einer DB zu laden
    local function loadServerState()
        currentSeasonIndex = 1
        local seasonData = Config.Seasons[currentSeasonIndex]
        currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
        currentWeather = weatherForSeason[seasonData.name][math.random(#weatherForSeason[seasonData.name])]
        print("[Weather Seasons] Standard-Jahreszeit geladen: " .. seasonData.name)
    end

    -- Funktion zum Wechseln des Wetters
    function changeWeather()
        local seasonName = Config.Seasons[currentSeasonIndex].name
        currentWeather = weatherForSeason[seasonName][math.random(#weatherForSeason[seasonName])]
        TriggerClientEvent('weather:setWeather', -1, currentWeather)
        print("[Weather Seasons] Wetter geändert zu: " .. currentWeather)
    end

    -- Funktion zum Wechseln zur nächsten Jahreszeit
    function changeSeason()
        currentSeasonIndex = (currentSeasonIndex % #Config.Seasons) + 1
        local seasonData = Config.Seasons[currentSeasonIndex]
        currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)

        saveServerState()
        changeWeather() -- Wetter passend zur neuen Jahreszeit ändern

        TriggerClientEvent('season:updateSeason', -1, seasonData.name, currentTemperature)
        TriggerClientEvent('season:notifySeasonChange', -1, seasonData.name)
        print("[Weather Seasons] Jahreszeit geändert zu: " .. seasonData.name)
    end

    -- Funktion zur regelmäßigen Anpassung der Temperatur
    function adjustTemperature()
        local seasonData = Config.Seasons[currentSeasonIndex]
        currentTemperature = math.random(seasonData.min_temp, seasonData.max_temp)
        TriggerClientEvent('weather_seasons:updateTemperature', -1, currentTemperature)
        print("[Weather Seasons] Temperatur angepasst auf: " .. currentTemperature .. "°C")
    end

    -- Admin-Befehl zum manuellen Wechseln der Jahreszeit
    RegisterCommand("nextseason", function(source, args, rawCommand)
        changeSeason()
        print("Admin hat die Jahreszeit manuell gewechselt.")
    end, false)

    -- Event-Handler für neue Spieler, um den aktuellen Status zu synchronisieren
    RegisterNetEvent('weather_seasons:requestSync', function()
        local src = source
        local seasonData = Config.Seasons[currentSeasonIndex]
        TriggerClientEvent('season:updateSeason', src, seasonData.name, currentTemperature)
        TriggerClientEvent('weather:setWeather', src, currentWeather)
    end)

    -- Initialen Server-Status laden
    loadServerState()

    -- Thread für den automatischen Wechsel der Jahreszeiten
    CreateThread(function()
        while true do
            Wait(Config.SeasonDurationSeconds * 1000)
            changeSeason()
        end
    end)

    -- Thread für die automatische Anpassung der Temperatur
    CreateThread(function()
        while true do
            Wait(Config.TemperatureChangeIntervalMinutes * 60 * 1000)
            adjustTemperature()
        end
    end)

    -- Thread für den automatischen Wechsel des Wetters
    CreateThread(function()
        while true do
            Wait(15 * 60 * 1000) -- Wetter alle 15 Minuten ändern
            changeWeather()
        end
    end)

    -- Exports für andere Skripte
    exports("GetCurrentSeason", function()
        return Config.Seasons[currentSeasonIndex].name
    end)
    exports("GetCurrentTemperature", function()
        return currentTemperature
    end)
    exports("IsHeatwaveActive", function()
        return currentTemperature >= Config.HeatwaveTemperature
    end)
    exports("GetCurrentWeather", function()
        return currentWeather
    end)
end)
=======
local currentSeason = "Frühling" -- Standardwert, falls keine Daten vorhanden sind
local seasonEffects = {
    ["Frühling"] = {weather = "CLEAR", transitionTime = 3000}, -- Übergangszeit für Frühling
    ["Sommer"] = {weather = "EXTRASUNNY", transitionTime = 3000}, -- Übergangszeit für Sommer
    ["Herbst"] = {weather = "FOGGY", transitionTime = 3000}, -- Übergangszeit für Herbst
    ["Winter"] = {weather = "XMAS", transitionTime = 3000} -- Übergangszeit für Winter
}

-- Datenbankverbindung sicherstellen
local oxmysql = exports.oxmysql

-- Funktion zum Speichern der Jahreszeit in die Datenbank
local function saveSeasonToDB()
    oxmysql:execute("UPDATE weather_seasons SET season = ? WHERE 1=1", {currentSeason})
end

-- Jahreszeit aus der Datenbank laden
local function loadSeasonFromDB()
    oxmysql:single("SELECT season FROM weather_seasons LIMIT 1", {}, function(result)
        if result and result.season then
            currentSeason = result.season
            print("[Weather Seasons] Geladene Jahreszeit: " .. currentSeason)
        else
            -- Falls keine Einträge existieren, Standardwert speichern
            oxmysql:execute("INSERT INTO weather_seasons (season) VALUES (?)", {currentSeason})
            print("[Weather Seasons] Standard-Jahreszeit gespeichert: " .. currentSeason)
        end
    end)
end

-- Funktion zum Wechseln der Jahreszeit
local function changeSeason()
    local seasons = {"Frühling", "Sommer", "Herbst", "Winter"}

    -- Index der aktuellen Jahreszeit bestimmen
    local currentIndex = nil
    for i, season in ipairs(seasons) do
        if season == currentSeason then
            currentIndex = i
            break
        end
    end

    -- Falls die aktuelle Jahreszeit nicht gefunden wird, auf Frühling setzen
    currentIndex = currentIndex or 1

    -- Nächste Jahreszeit bestimmen
    local nextSeasonIndex = (currentIndex % #seasons) + 1
    currentSeason = seasons[nextSeasonIndex]

    -- Speichere die neue Jahreszeit in der Datenbank
    saveSeasonToDB()

    -- Informiere alle Spieler über die neue Jahreszeit mit sanftem Übergang
    TriggerClientEvent('weather_seasons:updateSeason', -1, currentSeason, seasonEffects[currentSeason])
    print("[Weather Seasons] Jahreszeit geändert zu: " .. currentSeason)
end

-- Befehl für Admins zum Testen
RegisterCommand("changeSeason", function(source, args, rawCommand)
    if source == 0 then -- Server-Konsole
        changeSeason()
    else
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup() == "admin" then
            changeSeason()
        end
    end
end, false)

-- Sync für neue Spieler
RegisterNetEvent('weather_seasons:requestSync', function()
    local src = source
    TriggerClientEvent('weather_seasons:updateSeason', src, currentSeason, seasonEffects[currentSeason])
end)

-- Lade die gespeicherte Jahreszeit beim Serverstart
CreateThread(function()
    Wait(1000) -- Kurze Verzögerung, um sicherzustellen, dass die DB-Verbindung steht
    loadSeasonFromDB()
end)

-- Automatischer Wechsel der Jahreszeiten basierend auf der config.lua
CreateThread(function()
    while true do
        Wait(Config.SeasonDurationSeconds * 1000) -- korrekter Config-Name
        changeSeason()
    end
end)
