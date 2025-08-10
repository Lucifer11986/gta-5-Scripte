RegisterNetEvent('drug_system:beginRehab')
AddEventHandler('drug_system:beginRehab', function()
    local playerPed = PlayerPedId()
    local duration = Config.Rehab.duration * 60000 -- In Millisekunden

    -- Simuliere die Therapie durch visuelle Effekte
    DoScreenFadeOut(2000)
    Citizen.Wait(3000)
    
    SetEntityCoords(playerPed, -677.54, 315.83, 83.08) -- Beispielhafte Krankenhausposition
    Citizen.Wait(2000)
    DoScreenFadeIn(2000)

    Citizen.Wait(duration)

    TriggerEvent('esx:showNotification', 'Die Therapie ist abgeschlossen. Deine Sucht ist geheilt!')
end)

RegisterCommand('rehab', function(source, args)
    local targetId = tonumber(args[1]) -- Spieler-ID des Patienten

    if targetId then
        TriggerServerEvent('drug_system:startRehab', targetId)
    else
        print('Benutzung: /rehab [Spieler-ID]')
    end
end, false)
