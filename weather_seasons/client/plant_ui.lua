-- Effekte und UI für Pflanzen anzeigen
RegisterNetEvent("season:showPlantEffect")
AddEventHandler("season:showPlantEffect", function(plantId, message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end)

-- Aktualisiere Pflanzenanzeige im HUD
RegisterNetEvent("season:applyPlantVisuals")
AddEventHandler("season:applyPlantVisuals", function(plants)
    for _, plant in pairs(plants) do
        local growth = plant.growth or 0
        -- Logik zum Anzeigen des Pflanzenwachstums im HUD
        TriggerEvent("hud:updatePlantStatus", plant.id, growth)
    end
end)
