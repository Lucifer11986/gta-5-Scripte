ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('snowchains:apply')
AddEventHandler('snowchains:apply', function(vehicleNetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local vehicle = NetToVeh(vehicleNetId)

    if not DoesEntityExist(vehicle) then return end

    local vehicleClass = GetVehicleClass(vehicle)
    local requiredChains = Config.SnowChains.RequiredChains[vehicleClass]

    if requiredChains == nil or requiredChains == 0 then
        TriggerClientEvent('esx:showNotification', src, "An diesem Fahrzeug können keine Schneeketten angebracht werden.")
        return
    end

    local currentSeason = exports.weather_seasons:GetCurrentSeason()
    if currentSeason ~= "Winter" and Config.SnowChains.OffSeasonTireDamage then
        -- Strafe für die Nutzung außerhalb des Winters
        local chainCount = xPlayer.getInventoryItem(Config.SnowChains.ItemName).count
        if chainCount >= requiredChains then
            xPlayer.removeInventoryItem(Config.SnowChains.ItemName, requiredChains)
            TriggerClientEvent('snowchains:damageTires', src, vehicleNetId)
            TriggerClientEvent('esx:showNotification', src, "~r~Die Schneeketten haben deine Reifen auf dem trockenen Asphalt zerstört!")
        else
            TriggerClientEvent('esx:showNotification', src, "Du hast nicht genügend Schneeketten.")
        end
        return
    end

    -- Normale Anwendung im Winter
    local chainCount = xPlayer.getInventoryItem(Config.SnowChains.ItemName).count
    if chainCount >= requiredChains then
        xPlayer.removeInventoryItem(Config.SnowChains.ItemName, requiredChains)

        -- Status am Fahrzeug speichern
        local vehicleEntity = Entity(vehicle)
        vehicleEntity.state:set('hasSnowChains', true, true)
        vehicleEntity.state:set('snowChainsAppliedAt', os.time(), true)

        TriggerClientEvent('esx:showNotification', src, "Du hast erfolgreich " .. requiredChains .. " Schneeketten am Fahrzeug angebracht.")
        TriggerClientEvent('snowchains:applySuccess', src, vehicleNetId)
    else
        TriggerClientEvent('esx:showNotification', src, "Du hast nicht genügend Schneeketten (~r~" .. chainCount .. "/" .. requiredChains .. "~s~).")
    end
end)

RegisterNetEvent('snowchains:remove')
AddEventHandler('snowchains:remove', function(vehicleNetId)
    local src = source
    local vehicle = NetToVeh(vehicleNetId)
    if not DoesEntityExist(vehicle) then return end

    local vehicleEntity = Entity(vehicle)
    vehicleEntity.state:set('hasSnowChains', nil, true)
    vehicleEntity.state:set('snowChainsAppliedAt', nil, true)

    TriggerClientEvent('esx:showNotification', src, "Du hast die Schneeketten entfernt. Sie sind dabei kaputtgegangen.")
end)

-- Loop to check durability
Citizen.CreateThread(function()
    while true do
        -- Check every 5 minutes
        Citizen.Wait(5 * 60 * 1000)

        for _, vehicle in ipairs(GetVehicles()) do
            local vehicleEntity = Entity(vehicle)
            if vehicleEntity.state.hasSnowChains then
                local appliedAt = vehicleEntity.state.snowChainsAppliedAt
                if appliedAt and (os.time() - appliedAt) > (Config.SnowChains.DurabilityMinutes * 60) then

                    vehicleEntity.state:set('hasSnowChains', nil, true)
                    vehicleEntity.state:set('snowChainsAppliedAt', nil, true)

                    local owner = NetworkGetEntityOwner(vehicle)
                    if owner and GetPlayerName(owner) then
                         local xPlayer = ESX.GetPlayerFromId(owner)
                         if xPlayer then
                            TriggerClientEvent('esx:showNotification', xPlayer.source, "~r~Deine Schneeketten sind durch die Abnutzung kaputtgegangen.")
                         end
                    end
                end
            end
        end
    end
end)
