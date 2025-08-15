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
