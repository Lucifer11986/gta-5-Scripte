ESX = exports["es_extended"]:getSharedObject()

local pendingCallbacks = {}

-- Event vom Client mit Ergebnis
RegisterNetEvent('survival:responseIsWearingWarmClothes')
AddEventHandler('survival:responseIsWearingWarmClothes', function(isWearingWarm)
    local src = source
    if pendingCallbacks[src] then
        pendingCallbacks[src](isWearingWarm)
        pendingCallbacks[src] = nil
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Survival.CheckIntervalSeconds * 1000)
        local currentTemperature = exports.weather_seasons:GetCurrentTemperature()

        local players = ESX.GetPlayers()

        for i = 1, #players do
            local playerId = players[i]
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                -- Anfrage an Client senden und Callback speichern
                local cbDone = false
                pendingCallbacks[playerId] = function(isWearingWarm)
                    cbDone = true

                    -- Hitze-Logik
                    if currentTemperature >= Config.Survival.HotTemperature then
                        local multiplier = 1.0
                        if isWearingWarm then
                            multiplier = Config.Survival.ClothingMultiplier
                        end

                        local thirst = xPlayer.get('thirst')
                        xPlayer.set('thirst', math.max(thirst - (Config.Survival.ThirstRate * multiplier), 0))

                        if thirst <= 0 then
                            TriggerClientEvent('survival:applyDamage', playerId, Config.Survival.HeatDamage)
                            TriggerClientEvent('esx:showNotification', playerId, 'Du leidest an einem Hitzschlag! Finde schnell Wasser!')
                        end

                    -- Kälte-Logik
                    elseif currentTemperature <= Config.Survival.ColdTemperature then
                        if not isWearingWarm then
                            TriggerClientEvent('survival:applyDamage', playerId, Config.Survival.FreezingDamage)
                            TriggerClientEvent('esx:showNotification', playerId, 'Dir ist eiskalt! Zieh dir etwas Warmes an!')
                            TriggerClientEvent('survival:setFreezingEffect', playerId, true)
                        else
                            TriggerClientEvent('survival:setFreezingEffect', playerId, false)
                        end

                    else
                        TriggerClientEvent('survival:setFreezingEffect', playerId, false)
                    end
                end

                -- Client anfragen
                TriggerClientEvent('survival:requestIsWearingWarmClothes', playerId)

                -- Timeout fallback (z.B. nach 1 Sekunde ohne Antwort)
                Citizen.Wait(1000)
                if not cbDone then
                    -- Falls kein Callback, Behandlung hier (evtl Annahme false)
                    pendingCallbacks[playerId] = nil
                end
            end
        end
    end
end)
