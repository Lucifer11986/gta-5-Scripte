ESX = exports["es_extended"]:getSharedObject()

local spawnedPresents = {}
local presentBlips = {}
local presentModels = {}

-- Event, um die Geschenke vom Server zu erhalten und zu erstellen
RegisterNetEvent("winter_event:createPresents")
AddEventHandler("winter_event:createPresents", function(locations, models)
    presentModels = models
    for i, loc in ipairs(locations) do
        local model = presentModels[math.random(#presentModels)]
        RequestModel(model)
        Citizen.CreateThread(function()
            while not HasModelLoaded(model) do
                Citizen.Wait(100)
            end
            local present = CreateObject(model, loc, false, true, true)
            PlaceObjectOnGroundProperly(present)
            table.insert(spawnedPresents, present)

            local blip = AddBlipForCoord(loc)
            SetBlipSprite(blip, 128) -- Geschenk-Icon
            SetBlipColour(blip, 1) -- Rot
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Geschenk")
            EndTextCommandSetBlipName(blip)
            presentBlips[i] = blip
        end)
    end
end)

-- Schleife zur Überprüfung der Nähe zu Geschenken
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for i, present in ipairs(spawnedPresents) do
            if DoesEntityExist(present) then
                local presentCoords = GetEntityCoords(present)
                if #(coords - presentCoords) < 2.0 then
                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um das Geschenk aufzuheben.")
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerServerEvent("winter_event:findPresent", i)
                        DeleteObject(present)
                        RemoveBlip(presentBlips[i])
                        spawnedPresents[i] = nil
                        presentBlips[i] = nil
                    end
                    break
                end
            end
        end
    end
end)

-- Event, um die gefundenen Geschenke zu aktualisieren
RegisterNetEvent("winter_event:updatePresents")
AddEventHandler("winter_event:updatePresents", function(found)
    for index, _ in pairs(found) do
        if spawnedPresents[index] then
            DeleteObject(spawnedPresents[index])
            spawnedPresents[index] = nil
        end
        if presentBlips[index] then
            RemoveBlip(presentBlips[index])
            presentBlips[index] = nil
        end
    end
end)

-- Event zum Entfernen eines einzelnen Blips
RegisterNetEvent("winter_event:removePresentBlip")
AddEventHandler("winter_event:removePresentBlip", function(presentIndex)
    if presentBlips[presentIndex] then
        RemoveBlip(presentBlips[presentIndex])
        presentBlips[presentIndex] = nil
    end
end)

-- Event zum Entfernen ALLER Geschenke und Blips, wenn das Event endet
RegisterNetEvent("winter_event:removeAllPresents")
AddEventHandler("winter_event:removeAllPresents", function()
    for i, blip in pairs(presentBlips) do
        RemoveBlip(blip)
    end
    presentBlips = {}

    for i, present in pairs(spawnedPresents) do
        DeleteObject(present)
    end
    spawnedPresents = {}

end)

end)

