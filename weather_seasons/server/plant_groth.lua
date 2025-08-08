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

    OxMySQL.query("SELECT * FROM plants", {}, function(plants)
        for _, plant in pairs(plants) do
            -- **Wasser- und Gesundheitscheck**
            if plant.water <= 0 or plant.health <= 0 then
                OxMySQL.execute("DELETE FROM plants WHERE id = ?", {plant.id})
                print("[❌] Pflanze #" .. plant.id .. " ist vertrocknet oder gestorben!")
                return
            end

            -- **Wachstum berechnen**
            local newGrowth = plant.growth + (plant.base_growth_rate * growthModifier)
            if newGrowth > 100 then newGrowth = 100 end

            OxMySQL.update("UPDATE plants SET growth = ?, water = ?, health = ? WHERE id = ?", {
                newGrowth, plant.water - 2, plant.health - 1, plant.id
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
    OxMySQL.query("SELECT * FROM plants", {}, function(plants)
        TriggerClientEvent("season:applyPlantVisuals", src, plants)
    end)
end)

-- **Pflanzen gießen oder düngen**
RegisterNetEvent("season:revivePlant")
AddEventHandler("season:revivePlant", function(plantId, itemType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    OxMySQL.query("SELECT * FROM plants WHERE id = ?", {plantId}, function(result)
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
            OxMySQL.update("UPDATE plants SET health = ?, water = ? WHERE id = ?", {
                newHealth, newWater, plantId
            })
        end
    end)
end)
