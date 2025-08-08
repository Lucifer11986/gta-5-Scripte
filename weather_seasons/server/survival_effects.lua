ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    while true do
        -- Warte auf das in der Config festgelegte Intervall
        Citizen.Wait(Config.Survival.CheckInterval * 1000)

        -- Hole die aktuelle Temperatur vom Haupt-Wetterskript
        local currentTemperature = exports.weather_seasons:GetCurrentTemperature()

        -- Prüfe, ob die Temperatur hoch genug ist, um Hitzeeffekte auszulösen
        if currentTemperature >= Config.Survival.HotTemperature then
            local players = ESX.GetPlayers()

            for i = 1, #players do
                local xPlayer = ESX.GetPlayerFromId(players[i])

                if xPlayer then
                    -- Frage den Client nach dem Kleidungs-Multiplikator
                    ESX.TriggerServerCallback('survival:getClothingMultiplier', xPlayer.source, function(multiplier)
                        if multiplier then
                            local thirst = xPlayer.get('thirst')
                            local thirstRate = Config.Survival.ThirstRate * multiplier

                            -- Verringere den Durst des Spielers
                            xPlayer.set('thirst', thirst - thirstRate)

                            -- Prüfe auf Hitzschlag, wenn der Durst auf Null ist
                            if thirst <= 0 then
                                -- Füge Hitzschlagschaden zu
                                local playerPed = GetPlayerPed(xPlayer.source)
                                SetEntityHealth(playerPed, GetEntityHealth(playerPed) - Config.Survival.HeatDamage)
                                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Du leidest an einem Hitzschlag! Finde schnell Wasser!')
                            end
                        end
                    end)
                end
            end
        end
    end
end)
