ESX = exports["es_extended"]:getSharedObject()

local warmClothesResponses = {}

RegisterNetEvent('survival:responseWarmClothesStatus')
AddEventHandler('survival:responseWarmClothesStatus', function(isWearingWarm)
    local src = source
    warmClothesResponses[src] = isWearingWarm
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.Survival.CheckInterval * 1000)
        local currentTemperature = exports.weather_seasons:GetCurrentTemperature()
        local players = ESX.GetPlayers()

        for i = 1, #players do
            local playerId = players[i]
            warmClothesResponses[playerId] = nil
            TriggerClientEvent('survival:requestWarmClothesStatus', playerId)
        end

        Citizen.Wait(500) -- kurze Wartezeit für Client-Antworten

        for i = 1, #players do
            local playerId = players[i]
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if not xPlayer then goto continue end

            local isWearingWarm = warmClothesResponses[playerId] or false

            if currentTemperature >= Config.Survival.HotTemperature then
                local multiplier = isWearingWarm and Config.Survival.ClothingMultiplier or 1.0

                TriggerEvent('esx_status:getStatus', playerId, 'thirst', function(status)
                    local thirst = status.getPercent()
                    local newThirst = math.max(thirst - (Config.Survival.ThirstRate * multiplier), 0)
                    status.set(newThirst)

                    if newThirst <= 0 then
                        -- Health-Änderung an Client senden statt hier direkt SetEntityHealth
                        TriggerClientEvent('survival:applyHeatDamage', playerId, Config.Survival.HeatDamage)
                        TriggerClientEvent('esx:showNotification', playerId, 'Du leidest an einem Hitzschlag! Finde schnell Wasser!')
                    end
                end)

            elseif currentTemperature <= Config.Survival.ColdTemperature then
                if not isWearingWarm then
                    -- Health-Änderung an Client senden
                    TriggerClientEvent('survival:applyFreezingDamage', playerId, Config.Survival.FreezingDamage)
                    TriggerClientEvent('esx:showNotification', playerId, 'Dir ist eiskalt! Zieh dir etwas Warmes an!')
                    TriggerClientEvent('survival:setFreezingEffect', playerId, true)
                else
                    TriggerClientEvent('survival:setFreezingEffect', playerId, false)
                end
            else
                TriggerClientEvent('survival:setFreezingEffect', playerId, false)
            end

            ::continue::
        end
    end
end)
