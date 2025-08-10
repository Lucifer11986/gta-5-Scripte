RegisterNetEvent('drug_system:startDrugFreeEvent')
AddEventHandler('drug_system:startDrugFreeEvent', function()
    TriggerEvent('esx:showNotification', 'Ein Drogenfreier Monat beginnt! Keine Drogen für 30 Minuten = Belohnung!')
    
    Citizen.Wait(1800000) -- 30 Minuten
    TriggerServerEvent('drug_system:rewardForSobriety')
end)
