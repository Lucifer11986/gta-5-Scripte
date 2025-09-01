-- Fahrzeugbau Timer & Feedback
RegisterNetEvent('autobauer:client:productionStarted')
AddEventHandler('autobauer:client:productionStarted', function(vehicleName, duration)
    local timer = duration
    while timer > 0 do
        Wait(1000)
        timer = timer - 1
        SendNUIMessage({action="updateTimer", vehicleName=vehicleName, time=timer})
    end
    SendNUIMessage({action="productionComplete", vehicleName=vehicleName})
end)
