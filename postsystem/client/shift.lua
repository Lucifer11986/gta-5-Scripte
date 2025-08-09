ESX = exports["es_extended"]:getSharedObject()

-- Blip für Job-Annahmestelle erstellen
CreateThread(function()
    local jobLocation = Config.PostmanJob.JobLocation
    local blip = AddBlipForCoord(jobLocation.x, jobLocation.y, jobLocation.z)

    SetBlipSprite(blip, 408) -- Brief-Symbol
    SetBlipColour(blip, 2) -- Grün
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Postboten-Job")
    EndTextCommandSetBlipName(blip)
end)

-- Interaktionspunkt für Schichtsystem
CreateThread(function()
    while true do
        Wait(1000) -- Prüfe jede Sekunde

        local playerCoords = GetEntityCoords(PlayerPedId())
        local jobLocation = Config.PostmanJob.JobLocation
        local distance = #(playerCoords - vector3(jobLocation.x, jobLocation.y, jobLocation.z))

        if distance < 10.0 then -- Nur zeichnen, wenn in der Nähe
            DrawMarker(1, jobLocation.x, jobLocation.y, jobLocation.z - 0.98, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 0, 100, false, true, 2, nil, nil, false)

            if distance < 1.5 then
                local playerJob = ESX.GetPlayerData().job
                if playerJob and playerJob.name == Config.PostmanJob.JobName then
                    ESX.ShowHelpNotification("Drücke [E], um deine Schicht zu beenden.")
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerServerEvent('postsystem:endPostmanShift')
                    end
                else
                    ESX.ShowHelpNotification("Drücke [E], um als Postbote zu arbeiten.")
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerServerEvent('postsystem:startPostmanShift')
                    end
                end
            end
        end
    end
end)

-- Event zum Anziehen der Uniform
RegisterNetEvent('postsystem:setUniform')
AddEventHandler('postsystem:setUniform', function()
    local playerPed = PlayerPedId()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        local uniform = Config.PostmanJob.Uniform
        if skin.sex == 0 then -- Male
            TriggerEvent('skinchanger:loadClothes', skin, uniform.male)
        else -- Female
            TriggerEvent('skinchanger:loadClothes', skin, uniform.female)
        end
    end)
end)

-- Event zum Wiederherstellen der Kleidung
RegisterNetEvent('postsystem:restoreClothing')
AddEventHandler('postsystem:restoreClothing', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end)