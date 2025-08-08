RegisterNetEvent("season:showPlantEffect")
AddEventHandler("season:showPlantEffect", function(plantId, message)
    local plantEntity = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.5, GetHashKey("prop_plant"), false, false, false)
    if DoesEntityExist(plantEntity) then
        SetEntityHealth(plantEntity, GetEntityHealth(plantEntity) + 20)
        ShowSeasonNotification(message, 3)
    end
end)

-- **Pflanzenpflege mit Gießkanne, Wasserflasche oder Dünger**
RegisterCommand("pflegepflanze", function(_, args)
    local itemType = args[1] -- "watering_can", "water_bottle" oder "fertilizer"
    local playerCoords = GetEntityCoords(PlayerPedId())

    -- **Nächstgelegene Pflanze finden**
    for _, plant in pairs(plantEffects) do
        local distance = #(vector3(plant.x, plant.y, plant.z) - playerCoords)
        if distance < 2.0 then
            TriggerServerEvent("season:revivePlant", plant.id, itemType)
            return
        end
    end

    ShowSeasonNotification("🚫 Keine Pflanze in Reichweite!", 3)
end, false)
