local plantEffects = {}

-- **Effekte für das Wachstum der Pflanzen anzeigen**
RegisterNetEvent("season:applyPlantVisuals")
AddEventHandler("season:applyPlantVisuals", function(plantData)
    for _, plant in pairs(plantData) do
        local plantEntity = GetClosestObjectOfType(plant.x, plant.y, plant.z, 1.5, GetHashKey(plant.model), false, false, false)

        if DoesEntityExist(plantEntity) then
            if plant.growth >= 100 then
                SetEntityAlpha(plantEntity, 255, false)  -- Volle Sichtbarkeit bei 100% Wachstum
            else
                local alpha = math.floor(plant.growth * 2.55)
                SetEntityAlpha(plantEntity, alpha, false) -- Je nach Wachstum halbtransparent
            end

            if plant.health <= 20 then
                StartParticleFxLoopedOnEntity("ent_sht_flame", plantEntity, 0.0, 0.0, 0.0, 0, 0, 0, 1.0, false, false, false) 
            elseif plant.health <= 50 then
                StartParticleFxLoopedOnEntity("scr_weed_growth", plantEntity, 0.0, 0.0, 0.0, 0, 0, 0, 1.0, false, false, false) 
            else
                RemoveParticleFxFromEntity(plantEntity)
            end
        end
    end
end)

-- **Fordert die Server-Daten alle 10 Minuten an**
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000) -- 10 Minuten
        TriggerServerEvent("season:requestPlantData")
    end
end)
