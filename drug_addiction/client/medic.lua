RegisterNetEvent('drug_system:applyTherapy')
AddEventHandler('drug_system:applyTherapy', function(targetPlayer)
    local xPlayer = ESX.GetPlayerFromId(targetPlayer)

    if xPlayer.job.name == "medic" then
        -- Therapie-Prozess für die Drogenabhängigkeit
        TriggerServerEvent('drug_system:applyNewDrugEffects', "therapy", xPlayer.source)
        -- Erfolgreiche Therapie-Nachricht an den Spieler
        TriggerClientEvent('esx:showNotification', targetPlayer, 'Therapie erfolgreich! Du bist jetzt drogenfrei!')
    else
        -- Fehlernachricht, falls der Spieler kein Medic ist
        TriggerClientEvent('esx:showNotification', targetPlayer, 'Nur Mediziner können die Therapie durchführen!')
    end
end)
