RegisterServerEvent('drug_system:medicBuyMedication')
AddEventHandler('drug_system:medicBuyMedication', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.job.name == "medic" then
        local price = 500 -- Beispielpreis für das Medikament
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            TriggerClientEvent('esx:showNotification', src, 'Du hast ein Medikament gekauft!')
        else
            TriggerClientEvent('esx:showNotification', src, 'Du hast nicht genug Geld!')
        end
    else
        TriggerClientEvent('esx:showNotification', src, 'Nur Mediziner können dieses Medikament kaufen!')
    end
end)

RegisterServerEvent('drug_system:applyTherapy')
AddEventHandler('drug_system:applyTherapy', function(targetPlayer)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Überprüfen, ob der Spieler Mediziner ist
    if xPlayer.job.name == "medic" then
        -- Suchtwert des Zielspielers zurücksetzen
        local targetXPlayer = ESX.GetPlayerFromId(targetPlayer)
        if targetXPlayer then
            -- Hier wird die Drogenabhängigkeit des Zielspielers zurückgesetzt (kann an die Sucht-DB angepasst werden)
            MySQL.Async.execute('UPDATE users SET addiction_level = 0 WHERE identifier = @identifier', {
                ['@identifier'] = targetXPlayer.identifier
            })
            TriggerClientEvent('esx:showNotification', targetPlayer, 'Du wurdest erfolgreich von deiner Drogenabhängigkeit geheilt!')
        end
    else
        TriggerClientEvent('esx:showNotification', src, 'Du bist kein Mediziner!')
    end
end)
