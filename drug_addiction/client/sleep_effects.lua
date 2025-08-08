local sleepIssuesActive = false

RegisterNetEvent('drug_system:startSleepIssues')
AddEventHandler('drug_system:startSleepIssues', function()
    if sleepIssuesActive then return end
    sleepIssuesActive = true

    Citizen.CreateThread(function()
        while sleepIssuesActive do
            Citizen.Wait(30000) -- Alle 30 Sekunden  
            
            local playerPed = PlayerPedId()
            local stamina = GetPlayerSprintStaminaRemaining(PlayerId())

            -- Stamina schneller verbrauchen
            RestorePlayerStamina(PlayerId(), -50.0)

            -- Zufällige verschwommene Sicht simulieren
            if math.random(1, 4) == 1 then
                SetTimecycleModifier("DRUG_gas_huffin")
                Citizen.Wait(10000)
                SetTimecycleModifier("default")
            end
        end
    end)
end)

RegisterNetEvent('drug_system:stopSleepIssues')
AddEventHandler('drug_system:stopSleepIssues', function()
    sleepIssuesActive = false
end)
