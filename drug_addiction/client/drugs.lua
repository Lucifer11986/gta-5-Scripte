local addictionLevel = {} -- Speichert den Suchtlevel für jede Droge

RegisterNetEvent('drug_system:useDrug', function(drug)
    local drugData = Config.Drugs[drug]
    if not drugData then return end

    -- Effekte auslösen
    TriggerEvent('drug_system:applyEffect', drugData.effect)

    -- Suchtlevel erhöhen
    if not addictionLevel[drug] then addictionLevel[drug] = 0 end
    addictionLevel[drug] = addictionLevel[drug] + drugData.addictionRate

    -- Speichere den Suchtlevel auf dem Server
    TriggerServerEvent('drug_system:updateAddiction', drug, addictionLevel[drug])
end)

-- Effekte anwenden
RegisterNetEvent('drug_system:applyEffect', function(effect)
    if effect == "slowmo" then
        SetTimeScale(0.5)
        Citizen.Wait(15000)
        SetTimeScale(1.0)
    elseif effect == "speedboost" then
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
        Citizen.Wait(15000)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    elseif effect == "healthboost" then
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 20)
    end
end)
