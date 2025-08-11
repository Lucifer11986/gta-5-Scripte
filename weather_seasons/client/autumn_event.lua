ESX = exports["es_extended"]:getSharedObject()

local spawnedPumpkins = {}
local pumpkinBlips = {}
local pumpkinModels = {}

-- Event, um die Kürbisse vom Server zu erhalten und zu erstellen
RegisterNetEvent("autumn_event:createPumpkins")
AddEventHandler("autumn_event:createPumpkins", function(locations, models)
    pumpkinModels = models
    for i, loc in ipairs(locations) do
        local model = pumpkinModels[math.random(#pumpkinModels)]
        RequestModel(model)
        Citizen.CreateThread(function()
            while not HasModelLoaded(model) do
                Citizen.Wait(100)
            end
            local pumpkin = CreateObject(model, loc, false, true, true)
            PlaceObjectOnGroundProperly(pumpkin)
            table.insert(spawnedPumpkins, pumpkin)

            local blip = AddBlipForCoord(loc)
            SetBlipSprite(blip, 487) -- Kürbis-ähnliches Icon
            SetBlipColour(blip, 6) -- Orange
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Kürbis")
            EndTextCommandSetBlipName(blip)
            pumpkinBlips[i] = blip
        end)
    end
end)

-- Schleife zur Überprüfung der Nähe zu Kürbissen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for i, pumpkin in ipairs(spawnedPumpkins) do
            if DoesEntityExist(pumpkin) then
                local pumpkinCoords = GetEntityCoords(pumpkin)
                if #(coords - pumpkinCoords) < 2.0 then
                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um den Kürbis aufzuheben.")
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerServerEvent("autumn_event:findPumpkin", i)
                        DeleteObject(pumpkin)
                        RemoveBlip(pumpkinBlips[i])
                        spawnedPumpkins[i] = nil
                        pumpkinBlips[i] = nil
                    end
                    break
                end
            end
        end
    end
end)

-- Event, um die gefundenen Kürbisse zu aktualisieren
RegisterNetEvent("autumn_event:updatePumpkins")
AddEventHandler("autumn_event:updatePumpkins", function(found)
    for index, _ in pairs(found) do
        if spawnedPumpkins[index] then
            DeleteObject(spawnedPumpkins[index])
            spawnedPumpkins[index] = nil
        end
        if pumpkinBlips[index] then
            RemoveBlip(pumpkinBlips[index])
            pumpkinBlips[index] = nil
        end
    end
end)

-- Event zum Entfernen eines einzelnen Blips
RegisterNetEvent("autumn_event:removePumpkinBlip")
AddEventHandler("autumn_event:removePumpkinBlip", function(pumpkinIndex)
    if pumpkinBlips[pumpkinIndex] then
        RemoveBlip(pumpkinBlips[pumpkinIndex])
        pumpkinBlips[pumpkinIndex] = nil
    end
end)

-- Event zum Entfernen ALLER Kürbisse und Blips, wenn das Event endet
RegisterNetEvent("autumn_event:removeAllPumpkins")
AddEventHandler("autumn_event:removeAllPumpkins", function()
    for i, blip in pairs(pumpkinBlips) do
        RemoveBlip(blip)
    end
    pumpkinBlips = {}

    for i, pumpkin in pairs(spawnedPumpkins) do
        DeleteObject(pumpkin)
    end
    spawnedPumpkins = {}
end)