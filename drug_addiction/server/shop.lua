RegisterServerEvent('drug_system:medicBuyMedication')
AddEventHandler('drug_system:medicBuyMedication', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.job.name == "medic" then
        local price = 500 -- Preis des Medikaments
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            xPlayer.addInventoryItem('medication', 1)  -- Medikament als Item hinzufügen
            TriggerClientEvent('esx:showNotification', src, 'Du hast ein Medikament gekauft!')
        else
            TriggerClientEvent('esx:showNotification', src, 'Du hast nicht genug Geld!')
        end
    else
        TriggerClientEvent('esx:showNotification', src, 'Nur Mediziner können dieses Medikament kaufen!')
    end
end)

RegisterServerEvent('drug_system:buyRehabItem')
AddEventHandler('drug_system:buyRehabItem', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer or xPlayer.job.name ~= "ambulance" then
        TriggerClientEvent('esx:showNotification', src, 'Nur Mediziner können dieses Medikament kaufen!')
        return
    end

    if xPlayer.getMoney() >= Config.RehabCost then
        xPlayer.removeMoney(Config.RehabCost)
        xPlayer.addInventoryItem(Config.RehabItem, 1)
        TriggerClientEvent('esx:showNotification', src, 'Du hast ein Therapie-Medikament gekauft!')
    else
        TriggerClientEvent('esx:showNotification', src, 'Du hast nicht genug Geld für dieses Medikament.')
    end
end)
