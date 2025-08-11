-- Aktuelle Temperatur simulieren
local currentTemperature = 25 -- Standardwert (wird sich dynamisch ändern)

-- Funktion zum Abrufen der aktuellen Temperatur
function GetCurrentTemperature()
    return currentTemperature
end

-- Temperatur dynamisch ändern (abhängig von Jahreszeit)
CreateThread(function()
    while true do
        Wait(300000) -- Alle 5 Minuten
        local season = exports["weather_seasons"]:GetCurrentSeason()
        
        if season == "Summer" then
            currentTemperature = math.random(30, 40) -- Sommer: heiß
        elseif season == "Winter" then
            currentTemperature = math.random(-15, 9) -- Winter: kalt
        elseif season == "Spring" then
            currentTemperature = math.random(15, 25) -- Frühling: mild
        elseif season == "Autumn" then
            currentTemperature = math.random(10, 20) -- Herbst: kühl
        end

        print("[🌡] Neue Temperatur: " .. currentTemperature .. "°C")
    end
end)

-- Export für Temperaturabruf
exports("GetCurrentTemperature", function()
    return GetCurrentTemperature()
end)
