local isPostman = false
local currentDeliveries = {}
local savedClothing = {} -- Tabelle zum Speichern der Kleidung

-- Jobannahme-Stelle
local jobLocation = vector3(248.6752, -825.1993, 29.8444) -- Koordinaten für die Jobannahme-Stelle

-- NPC-Modell
local npcModel = "s_m_m_postal_01"

-- Funktion zum Spawnen des NPCs
function SpawnJobNPC()
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Citizen.Wait(10)
    end

    -- Spawne den NPC an der Jobannahme-Stelle
    local npc = CreatePed(4, npcModel, jobLocation.x, jobLocation.y, jobLocation.z - 1.0, 337.4777, false, true)
    SetEntityHeading(npc, 337.4777) -- Ausrichtung des NPCs
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end

-- Funktion zum Anzeigen von 3D-Text
function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

-- Funktion zum Spawnen eines Postboten-Fahrzeugs
function SpawnPostmanVehicle(vehicleModel)
    local spawnCoords = vector3(232.0914, -804.9623, 30.4716) -- Koordinaten für den Fahrzeug-Spawn
    local spawnHeading = 70.8697 -- Ausrichtung des Fahrzeugs

    -- Fahrzeug spawnen
    ESX.Game.SpawnVehicle(vehicleModel, spawnCoords, spawnHeading, function(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1) -- Spieler ins Fahrzeug setzen
        SetVehicleNumberPlateText(vehicle, "POST" .. math.random(1000, 9999)) -- Nummernschild setzen
        SetVehicleFuelLevel(vehicle, 100.0) -- Tank voll
        TriggerEvent("esx:showNotification", "🚚 Postboten-Fahrzeug gespawnt!")
    end)
end

-- Funktion zum Speichern der aktuellen Kleidung
function SaveCurrentClothing()
    local playerPed = PlayerPedId()
    savedClothing = {
        tshirt_1 = GetPedDrawableVariation(playerPed, 8),
        tshirt_2 = GetPedTextureVariation(playerPed, 8),
        torso_1 = GetPedDrawableVariation(playerPed, 11),
        torso_2 = GetPedTextureVariation(playerPed, 11),
        arms = GetPedDrawableVariation(playerPed, 3),
        pants_1 = GetPedDrawableVariation(playerPed, 4),
        pants_2 = GetPedTextureVariation(playerPed, 4),
        shoes_1 = GetPedDrawableVariation(playerPed, 6),
        shoes_2 = GetPedTextureVariation(playerPed, 6)
    }
end

-- Funktion zum Wiederherstellen der gespeicherten Kleidung
function RestoreSavedClothing()
    local playerPed = PlayerPedId()
    if savedClothing then
        SetPedComponentVariation(playerPed, 8, savedClothing.tshirt_1, savedClothing.tshirt_2, 2) -- T-Shirt
        SetPedComponentVariation(playerPed, 11, savedClothing.torso_1, savedClothing.torso_2, 2) -- Oberkörper
        SetPedComponentVariation(playerPed, 3, savedClothing.arms, 0, 2) -- Arme
        SetPedComponentVariation(playerPed, 4, savedClothing.pants_1, savedClothing.pants_2, 2) -- Hose
        SetPedComponentVariation(playerPed, 6, savedClothing.shoes_1, savedClothing.shoes_2, 2) -- Schuhe
    else
        TriggerEvent("esx:showNotification", "❌ Es wurde keine gespeicherte Kleidung gefunden!")
    end
end

-- Funktion zum Abrufen der Spielerkoordinaten
function GetPlayerCoords(playerId)
    local player = GetPlayerPed(playerId)
    return GetEntityCoords(player)
end

-- Funktion zum Hinzufügen von Geld
function AddMoney(playerId, amount)
    local player = ESX.GetPlayerFromId(playerId)
    if player then
        player.addMoney(amount)
        TriggerClientEvent("esx:showNotification", playerId, "Du hast $" .. amount .. " erhalten!")
    end
end

-- Funktion zum Öffnen des Jobannahme-Menüs
function OpenPostmanMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'postman_menu', {
        title = 'Postboten-Job',
        align = 'top-left',
        elements = {
            { label = 'Postbote annehmen', value = 'accept_job' },
            { label = 'Job beenden', value = 'quit_job' },
            { label = 'Schließen', value = 'close' }
        }
    }, function(data, menu)
        if data.current.value == 'accept_job' then
            -- Postbote annehmen
            SaveCurrentClothing() -- Kleidung speichern
            TriggerServerEvent("postsystem:acceptPostmanJob")
            menu.close()
        elseif data.current.value == 'quit_job' then
            -- Job beenden
            TriggerServerEvent("postsystem:quitPostmanJob")
            menu.close()
        elseif data.current.value == 'close' then
            -- Menü schließen
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Funktion zum Öffnen des Fahrzeug-Menüs
function OpenVehicleMenu()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
        title = 'Fahrzeug ausparken',
        align = 'top-left',
        elements = {
            { label = 'Fahrzeug ausparken', value = 'spawn_vehicle' },
            { label = 'Schließen', value = 'close' }
        }
    }, function(data, menu)
        if data.current.value == 'spawn_vehicle' then
            -- Fahrzeug spawnen
            local vehicleModel = Config.PostmanJob.Vehicles[1].model -- Beispiel: Erstes Fahrzeug in der Liste
            SpawnPostmanVehicle(vehicleModel)
            menu.close()
        elseif data.current.value == 'close' then
            -- Menü schließen
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Jobannahme-Stelle
CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - jobLocation)

        if distance < 2.0 then
            DrawText3D(jobLocation, "Drücke ~g~[E]~w~, um das Menü zu öffnen")

            if IsControlJustReleased(0, 38) then -- 38 ist der Keycode für die E-Taste
                if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.PostmanJob.JobName then
                    -- Spieler ist bereits Postbote: Fahrzeug-Menü öffnen
                    OpenVehicleMenu()
                else
                    -- Spieler ist kein Postbote: Jobannahme-Menü öffnen
                    OpenPostmanMenu()
                end
            end
        end
    end
end)

-- Postboten-Job starten
RegisterNetEvent("postsystem:startPostJob")
AddEventHandler("postsystem:startPostJob", function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.PostmanJob.JobName then
        isPostman = true
        TriggerServerEvent("postsystem:fetchDeliveries")
        TriggerEvent("esx:showNotification", "Du hast den Postboten-Job gestartet!")
    else
        TriggerEvent("esx:showNotification", "Du bist kein Postbote!")
    end
end)

-- Zustellungen erhalten
RegisterNetEvent("postsystem:startDeliveries")
AddEventHandler("postsystem:startDeliveries", function(deliveries)
    currentDeliveries = deliveries
    TriggerEvent("esx:showNotification", "Du hast " .. #deliveries .. " Zustellungen erhalten.")
    StartDeliveries()
end)

-- Zustellungen durchführen
function StartDeliveries()
    for _, delivery in ipairs(currentDeliveries) do
        local receiverCoords = vector3(delivery.x, delivery.y, delivery.z) -- Beispielkoordinaten für die Zustellung
        SetNewWaypoint(receiverCoords.x, receiverCoords.y)

        TriggerEvent("esx:showNotification", "Zustellung an " .. delivery.receiver)

        -- Warte, bis der Postbote am Zielort ist
        while #(GetEntityCoords(PlayerPedId()) - receiverCoords) > 5.0 do
            Citizen.Wait(1000)
        end

        -- Zustellung abschließen
        TriggerServerEvent("postsystem:completeDelivery", delivery.id, delivery.type)
        TriggerEvent("esx:showNotification", "Zustellung abgeschlossen!")
    end

    -- Job beenden, wenn alle Zustellungen erledigt sind
    isPostman = false
    TriggerEvent("esx:showNotification", "Alle Zustellungen erledigt! Job beendet.")
end

-- Event zum Wiederherstellen der normalen Kleidung
RegisterNetEvent("postsystem:restoreNormalClothing")
AddEventHandler("postsystem:restoreNormalClothing", function()
    RestoreSavedClothing() -- Gespeicherte Kleidung wiederherstellen
end)

-- Spawne den NPC beim Start
CreateThread(function()
    SpawnJobNPC()
end)