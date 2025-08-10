ESX = exports["es_extended"]:getSharedObject()

-- Haupt-Schleife, die den Client zur Überprüfung auffordert
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Survival.CheckInterval * 1000)

        local players = ESX.GetPlayers()
        for i = 1, #players do
            local xPlayer = ESX.GetPlayerFromId(players[i])
            if xPlayer then
                local currentTemperature = exports.weather_seasons:GetCurrentTemperature()
                -- Fordere den Client auf, die Kleidung zu prüfen und die Effekte anzuwenden
                TriggerClientEvent('survival:checkClothingAndApplyEffects', xPlayer.source, currentTemperature)
            end
        end
    end
end)

-- Event-Handler, der die Antwort vom Client empfängt und die Logik anwendet
RegisterNetEvent('survival:applyEffects')
AddEventHandler('survival:applyEffects', function(isWearingWarm, temperature)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    -- Logik für Hitze
    if temperature >= Config.Survival.HotTemperature then
        local multiplier = 1.0
        if isWearingWarm then
            multiplier = Config.Survival.ClothingMultiplier
        end

        local thirst = xPlayer.get('thirst')
        xPlayer.set('thirst', thirst - (Config.Survival.ThirstRate * multiplier))

        if thirst <= 0 then
            local playerPed = GetPlayerPed(xPlayer.source)
            SetEntityHealth(playerPed, GetEntityHealth(playerPed) - Config.Survival.HeatDamage)
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Du leidest an einem Hitzschlag! Finde schnell Wasser!')
        end

    -- Logik für Kälte
    elseif temperature <= Config.Survival.ColdTemperature then
        if not isWearingWarm then
            local playerPed = GetPlayerPed(xPlayer.source)
            SetEntityHealth(playerPed, GetEntityHealth(playerPed) - Config.Survival.FreezingDamage)
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Dir ist eiskalt! Zieh dir etwas Warmes an!')
            TriggerClientEvent('survival:setFreezingEffect', xPlayer.source, true)
        else
            TriggerClientEvent('survival:setFreezingEffect', xPlayer.source, false)
        end

    -- Weder zu heiß noch zu kalt
    else
        TriggerClientEvent('survival:setFreezingEffect', xPlayer.source, false)
    end
end)
