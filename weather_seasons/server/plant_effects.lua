-- **Sicherstellen, dass GetCurrentWeather existiert**
if not GetCurrentWeather then
    function GetCurrentWeather()
        print("[⚠️] GetCurrentWeather() ist nicht definiert! Verwende Standardwert 'Clear'.")
        return "Clear" -- Standard-Wert, falls die Wetterfunktion nicht existiert
    end
end

local function ApplyWeatherEffects()
    local currentWeather = GetCurrentWeather() -- Holt Wetter aus `weather_seasons.lua`
    local currentSeason = GetCurrentSeason()   -- Holt Jahreszeit aus `weather_seasons.lua`

    if not currentWeather or not currentSeason then
        print("[❌] Fehler: Wetter oder Jahreszeit konnte nicht geladen werden!")
        return
    end

    exports.oxmysql:execute("SELECT * FROM plants", {}, function(plants)
        if not plants or #plants == 0 then
            print("[🌱] Keine Pflanzen in der Datenbank gefunden.")
            return
        end

        for _, plant in pairs(plants) do
            local healthModifier = 0
            local waterModifier = 0

            -- **Effekte durch Wetter**
            if currentWeather == "Rain" or currentWeather == "Thunder" then
                waterModifier = 15  -- Regen füllt Wasser auf
                healthModifier = 5   -- Regen stärkt Pflanzen leicht
            elseif currentWeather == "Clear" and currentSeason == "Sommer" then
                healthModifier = -10 -- Zu viel Sonne schadet
                waterModifier = -10  -- Wasser verdunstet schneller
            elseif currentWeather == "Snow" and currentSeason == "Winter" then
                healthModifier = -20 -- Frost schadet Pflanzen stark
                waterModifier = -5   -- Gefrorenes Wasser verringert Versorgung
            elseif currentWeather == "Fog" then
                healthModifier = -2  -- Leichter Stress durch Feuchtigkeit
            end

            -- **Neue Werte berechnen**
            local newHealth = (plant.health or 0) + healthModifier  -- Default-Wert für health, falls nil
            local newWater = (plant.water or 0) + waterModifier    -- Default-Wert für water, falls nil

            -- **Grenzwerte setzen**
            newHealth = math.max(0, math.min(100, newHealth))
            newWater = math.max(0, math.min(100, newWater))

            -- **Pflanzen sterben, wenn sie zu schwach sind**
            if newHealth <= 0 or newWater <= 0 then
                exports.oxmysql:execute("DELETE FROM plants WHERE id = ?", {plant.id})
                print("[❌] Pflanze #" .. plant.id .. " ist gestorben.")
            else
                -- **Pflanzen aktualisieren**
                exports.oxmysql:execute("UPDATE plants SET health = ?, water = ? WHERE id = ?", {
                    newHealth, newWater, plant.id
                })
            end
        end
    end)
end

-- **Wettereffekte alle 5 Minuten anwenden**
CreateThread(function()
    while true do
        Wait(300000)  -- 5 Minuten
        ApplyWeatherEffects()
    end
end)
