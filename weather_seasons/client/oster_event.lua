ESX = exports["es_extended"]:getSharedObject()

local spawnedEggs = {}
local eggBlips = {}
local eggModels = {}

-- Event, um die Eier vom Server zu erhalten und zu erstellen
RegisterNetEvent("easter_event:createEggs")
AddEventHandler("easter_event:createEggs", function(locations, models)
    eggModels = models

    for i, loc in ipairs(locations) do
        local model = GetHashKey(eggModels[math.random(#eggModels)])
        RequestModel(model)

        Citizen.CreateThread(function()
            while not HasModelLoaded(model) do
                Citizen.Wait(100)
            end

            -- Osterei erstellen
            local egg = CreateObject(model, loc.x, loc.y, loc.z, false, true, true)
            PlaceObjectOnGroundProperly(egg)
            spawnedEggs[i] = egg

            -- Blip für das Ei
            local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
            SetBlipSprite(blip, 358)       -- Blip-Symbol
            SetBlipColour(blip, 2)        -- Grün
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

                    if IsControlJustReleased(0, 38) then -- Taste E
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
