RegisterServerEvent('drug_system:startRehab')
AddEventHandler('drug_system:startRehab', function(targetId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not xPlayer or not targetPlayer then return end

    -- Prüfen, ob der Spieler Medic ist
    if xPlayer.job.name ~= "ambulance" then
        TriggerClientEvent('esx:showNotification', src, 'Nur Medics können eine Therapie durchführen!')
        return
    end

    -- Prüfen, ob der Medic das Medikament hat
    local item = xPlayer.getInventoryItem(Config.RehabItem)
    if item.count < 1 then
        TriggerClientEvent('esx:showNotification', src, 'Du benötigst das Medikament "' .. Config.RehabItem .. '"!')
        return
    end

    -- Medikament verbrauchen
    xPlayer.removeInventoryItem(Config.RehabItem, 1)

    -- Kosten werden vom Patienten abgezogen
    local cost = Config.Rehab.cost
    if targetPlayer.getAccount('bank').money >= cost then
        targetPlayer.removeAccountMoney('bank', cost)
        
        -- Therapie starten
        TriggerClientEvent('drug_system:beginRehab', targetId)
        MySQL.update('UPDATE users SET addiction = 0 WHERE identifier = ?', { targetPlayer.identifier })
        
        -- Benachrichtigungen senden
        TriggerClientEvent('esx:showNotification', src, 'Du hast die Therapie erfolgreich durchgeführt!')
        TriggerClientEvent('esx:showNotification', targetId, 'Ein Medic hat deine Therapie gestartet.')
    else
        TriggerClientEvent('esx:showNotification', src, 'Der Patient hat nicht genug Geld für die Therapie.')
    end
end)
