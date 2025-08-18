RegisterServerEvent('drug_system:sellDrug')
AddEventHandler('drug_system:sellDrug', function(targetId, drug, amount, price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not xPlayer or not targetPlayer then return end

    -- Prüfen, ob der Verkäufer die Drogen besitzt
    local item = xPlayer.getInventoryItem(drug)
    if item.count < amount then
        TriggerClientEvent('esx:showNotification', src, 'Du hast nicht genug von dieser Droge!')
        return
    end

    -- Prüfen, ob der Käufer genug Geld hat
    if targetPlayer.getMoney() >= price then
        xPlayer.removeInventoryItem(drug, amount)
        xPlayer.addMoney(price)
        targetPlayer.removeMoney(price)
        targetPlayer.addInventoryItem(drug, amount)

        TriggerClientEvent('esx:showNotification', src, 'Du hast ' .. amount .. 'x ' .. drug .. ' für ' .. price .. '$ verkauft.')
        TriggerClientEvent('esx:showNotification', targetId, 'Du hast ' .. amount .. 'x ' .. drug .. ' für ' .. price .. '$ gekauft.')
    else
        TriggerClientEvent('esx:showNotification', src, 'Der Käufer hat nicht genug Geld.')
    end
end)
