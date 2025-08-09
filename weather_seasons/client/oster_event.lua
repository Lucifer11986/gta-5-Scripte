ESX = exports["es_extended"]:getSharedObject()

local spawnedEggs = {}
local eggBlips = {}
local eggModels = {}

-- Event, um die Eier vom Server zu erhalten und zu erstellen
RegisterNetEvent("easter_event:createEggs")
AddEventHandler("easter_event:createEggs", function(locations, models)
    eggModels = models
    for i, loc in ipairs(locations) do
        local model = eggModels[math.random(#eggModels)]
        RequestModel(model)
        Citizen.CreateThread(function()
            while not HasModelLoaded(model) do
                Citizen.Wait(100)
            end
            local egg = CreateObject(model, loc, false, true, true)
            PlaceObjectOnGroundProperly(egg)
            table.insert(spawnedEggs, egg)

            local blip = AddBlipForCoord(loc)
            SetBlipSprite(blip, 358)
            SetBlipColour(blip, 2)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Osterei")
            EndTextCommandSetBlipName(blip)
            eggBlips[i] = blip
        end)
    end
end)

-- Schleife zur Überprüfung der Nähe zu Eiern
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for i, egg in ipairs(spawnedEggs) do
            if DoesEntityExist(egg) then
                local eggCoords = GetEntityCoords(egg)
                if #(coords - eggCoords) < 2.0 then
                    ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um das Osterei aufzuheben.")
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerServerEvent("easter_event:findEgg", i)
                        DeleteObject(egg)
                        RemoveBlip(eggBlips[i])
                        spawnedEggs[i] = nil
                        eggBlips[i] = nil
                    end
                    break
                end
            end
        end
    end
end)

-- Event, um die gefundenen Eier zu aktualisieren
RegisterNetEvent("easter_event:updateEggs")
AddEventHandler("easter_event:updateEggs", function(found)
    for index, _ in pairs(found) do
        if spawnedEggs[index] then
            DeleteObject(spawnedEggs[index])
            spawnedEggs[index] = nil
        end
        if eggBlips[index] then
            RemoveBlip(eggBlips[index])
            eggBlips[index] = nil
        end
    end
end)

-- Event zum Entfernen eines einzelnen Blips
RegisterNetEvent("easter_event:removeEggBlip")
AddEventHandler("easter_event:removeEggBlip", function(eggIndex)
    if eggBlips[eggIndex] then
        RemoveBlip(eggBlips[eggIndex])
        eggBlips[eggIndex] = nil
    end
end)

-- Event zum Entfernen ALLER Eier und Blips, wenn das Event endet
RegisterNetEvent("easter_event:removeAllEggs")
AddEventHandler("easter_event:removeAllEggs", function()
    for i, blip in pairs(eggBlips) do
        RemoveBlip(blip)
    end
    eggBlips = {}

    for i, egg in pairs(spawnedEggs) do
        DeleteObject(egg)
    end
    spawnedEggs = {}
end)