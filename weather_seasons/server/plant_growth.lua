local plantGrowthStages = {
    ["Frühling"] = 1.2,  -- Wachstum 20% schneller
    ["Sommer"] = 1.5,    -- Wachstum 50% schneller
    ["Herbst"] = 1.0,    -- Normales Wachstum
    ["Winter"] = 0.5     -- Wachstum 50% langsamer
}

local function GetSeasonGrowthModifier(season)
    return plantGrowthStages[season] or 1.0
end

function UpdatePlantGrowth()
    local currentSeason = GetCurrentSeason()
    local growthModifier = GetSeasonGrowthModifier(currentSeason)

    -- Sicherstellen, dass die 'plants' Tabelle existiert
    exports.oxmysql:execute([[ 
        CREATE TABLE IF NOT EXISTS plants ( 
            id INT AUTO_INCREMENT PRIMARY KEY, 
            plant_name VARCHAR(255), 
            growth INT, 
            water INT, 
            health INT, 
            base_growth_rate INT, 
            last_growth_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ); 
    ]], {}, function(result)
        if result then
            print("[✔️] Tabelle 'plants' wurde erfolgreich überprüft oder erstellt.")
        else
            print("[❌] Fehler beim Erstellen oder Überprüfen der 'plants' Tabelle!")
        end
    end)

    -- Abfrage nach Pflanzen
    exports.oxmysql:execute("SELECT * FROM plants", {}, function(plants)
        if not plants or #plants == 0 then
            print("[🌱] Keine Pflanzen in der Datenbank gefunden.")
            return
        end

        for _, plant in pairs(plants) do
            -- **Wasser- und Gesundheitscheck**
            if plant.water and plant.water <= 0 or plant.health and plant.health <= 0 then
                exports.oxmysql:execute("DELETE FROM plants WHERE id = ?", {plant.id})
                print("[❌] Pflanze #" .. plant.id .. " ist vertrocknet oder gestorben!")
                return
            end

            -- **Wachstum berechnen**
            local baseGrowthRate = plant.base_growth_rate or 1 -- Standardwert auf 1 setzen, falls nil
            local newGrowth = plant.growth + (baseGrowthRate * growthModifier)
            if newGrowth > 100 then newGrowth = 100 end

            exports.oxmysql:execute("UPDATE plants SET growth = ?, water = ?, health = ? WHERE id = ?", {
                newGrowth, (plant.water or 0) - 2, (plant.health or 0) - 1, plant.id
            })

            if newGrowth == 100 then
                print("[🌱] Pflanze #" .. plant.id .. " ist ausgewachsen!")
            end
        end
    end)
end

-- **Pflanzenwachstum alle 10 Minuten aktualisieren**
CreateThread(function()
    while true do
        Wait(600000) -- 10 Minuten
        UpdatePlantGrowth()
    end
end)

RegisterServerEvent("season:requestPlantData")
AddEventHandler("season:requestPlantData", function()
    local src = source

    -- Sicherstellen, dass die 'plants' Tabelle existiert
    exports.oxmysql:execute([[ 
        CREATE TABLE IF NOT EXISTS plants ( 
            id INT AUTO_INCREMENT PRIMARY KEY, 
            plant_name VARCHAR(255), 
            growth INT, 
            water INT, 
            health INT, 
            base_growth_rate INT, 
            last_growth_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ); 
    ]], {}, function(result)
        if result then
            print("[✔️] Tabelle 'plants' wurde erfolgreich überprüft oder erstellt.")
        else
            print("[❌] Fehler beim Erstellen oder Überprüfen der 'plants' Tabelle!")
        end
    end)

    -- Abfrage nach Pflanzen
    exports.oxmysql:execute("SELECT * FROM plants", {}, function(plants)
        TriggerClientEvent("season:applyPlantVisuals", src, plants)
    end)
end)

-- **Pflanzen gießen oder düngen**
RegisterNetEvent("season:revivePlant")
AddEventHandler("season:revivePlant", function(plantId, itemType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Sicherstellen, dass die 'plants' Tabelle existiert
    exports.oxmysql:execute([[ 
        CREATE TABLE IF NOT EXISTS plants ( 
            id INT AUTO_INCREMENT PRIMARY KEY, 
            plant_name VARCHAR(255), 
            growth INT, 
            water INT, 
            health INT, 
            base_growth_rate INT, 
            last_growth_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
        ); 
    ]], {}, function(result)
        if result then
            print("[✔️] Tabelle 'plants' wurde erfolgreich überprüft oder erstellt.")
        else
            print("[❌] Fehler beim Erstellen oder Überprüfen der 'plants' Tabelle!")
        end
    end)

    local result = exports.oxmysql:executeSync("SELECT * FROM plants WHERE id = ?", {plantId})

    if result[1] then
        local plant = result[1]
        local newHealth = plant.health
        local newWater = plant.water

        -- **Gießen mit Gießkanne oder Wasserflasche**
        if itemType == "watering_can" and xPlayer.getInventoryItem("watering_can").count > 0 then
            newWater = math.min(100, newWater + 40)
            TriggerClientEvent("season:showPlantEffect", src, plantId, "💧 Pflanze mit Gießkanne gegossen!")

        elseif itemType == "water_bottle" and xPlayer.getInventoryItem("water_bottle").count > 0 then
            xPlayer.removeInventoryItem("water_bottle", 1)
            newWater = math.min(100, newWater + 20)
            TriggerClientEvent("season:showPlantEffect", src, plantId, "💧 Pflanze mit Wasserflasche gegossen!")

        -- **Düngen**
        elseif itemType == "fertilizer" and xPlayer.getInventoryItem("fertilizer").count > 0 then
            xPlayer.removeInventoryItem("fertilizer", 1)
            newHealth = math.min(100, newHealth + 40)
            TriggerClientEvent("season:showPlantEffect", src, plantId, "🌱 Pflanze gedüngt!")

        else
            TriggerClientEvent("season:showPlantEffect", src, plantId, "⚠️ Kein passendes Item!")
            return
        end

        -- **Datenbank aktualisieren**
        exports.oxmysql:execute("UPDATE plants SET health = ?, water = ? WHERE id = ?", {
            newHealth, newWater, plantId
        })
    end
end)
