ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Survival.CheckInterval * 1000)
        local currentTemperature = exports.weather_seasons:GetCurrentTemperature()

        local players = ESX.GetPlayers()

        for i = 1, #players do
            local xPlayer = ESX.GetPlayerFromId(players[i])
            if xPlayer then
                -- Frage den Client einmal pro Schleife nach dem Kleidungsstatus
                ESX.TriggerServerCallback('survival:isWearingWarmClothes', xPlayer.source, function(isWearingWarm)

                    -- Logik für Hitze
                    if currentTemperature >= Config.Survival.HotTemperature then
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
                    elseif currentTemperature <= Config.Survival.ColdTemperature then
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
            end
        end
    end
end)
