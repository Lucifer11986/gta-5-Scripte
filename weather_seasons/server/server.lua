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
        Wait(Config.SeasonDuration * 1000) -- Config-Wert nutzen
        changeSeason()
    end
end)
