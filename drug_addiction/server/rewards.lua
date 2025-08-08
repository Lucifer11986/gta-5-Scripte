RegisterServerEvent('drug_system:rewardForSobriety')
AddEventHandler('drug_system:rewardForSobriety', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.single('SELECT addiction FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result and result.addiction <= 5 then
            xPlayer.addMoney(1000)
            TriggerClientEvent('esx:showNotification', src, 'Du hast 1.000$ für deinen Entzug erhalten!')
        end
    end)
end)
