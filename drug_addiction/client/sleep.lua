local isSleeping = false

RegisterNetEvent('drug_system:applySleepIssues')
AddEventHandler('drug_system:applySleepIssues', function()
    local playerPed = PlayerPedId()
    if not isSleeping then
        isSleeping = true
        SetEntityInvincible(playerPed, true)
        TriggerEvent('esx:showNotification', 'Du hast Schlafprobleme wegen deiner Drogenabhängigkeit!')
        Citizen.Wait(30000)
        SetEntityInvincible(playerPed, false)
        isSleeping = false
    end
end)
