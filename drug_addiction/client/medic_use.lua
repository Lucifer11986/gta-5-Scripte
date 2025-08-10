RegisterNetEvent('drug_system:useMedication')
AddEventHandler('drug_system:useMedication', function(targetPlayer)
    local xPlayer = ESX.GetPlayerFromId(targetPlayer)

    -- Überprüfen, ob der Spieler Mediziner ist
    if xPlayer.job.name == "medic" then
        -- Medizin anwenden
        TriggerServerEvent('drug_system:applyTherapy', targetPlayer)
        -- Erfolgreiche Therapie-Nachricht an den Spieler
        TriggerClientEvent('esx:showNotification', targetPlayer, 'Therapie erfolgreich durchgeführt!')
        TriggerClientEvent('esx:showNotification', targetPlayer, 'Du bist jetzt drogenfrei!')
        
        -- Medikament aus dem Inventar entfernen
        xPlayer.removeInventoryItem('medication', 1)
    else
        -- Fehlernachricht, falls der Spieler kein Mediziner ist
        TriggerClientEvent('esx:showNotification', targetPlayer, 'Nur Mediziner können die Therapie durchführen!')
    end
end)
