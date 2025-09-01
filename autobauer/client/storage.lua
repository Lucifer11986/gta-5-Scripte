-- Material- und Fahrzeuglager Interaktionen
-- Leeres Grundgerüst
-- Materiallager & Fahrzeuglager abrufen
RegisterNetEvent('autobauer:client:refreshStorage')
AddEventHandler('autobauer:client:refreshStorage', function()
    ESX.TriggerServerCallback('autobauer:server:getMaterials', function(materials)
        SendNUIMessage({action="updateMaterials", materials=materials})
    end)

    ESX.TriggerServerCallback('autobauer:server:getStorageCars', function(cars)
        SendNUIMessage({action="updateCars", cars=cars})
    end)
end)
