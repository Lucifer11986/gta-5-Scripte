ESX = exports["es_extended"]:getSharedObject()

local currentRoute = {}
local currentDeliveryIndex = 0
local routeBlip = nil

-- Funktion zum Starten/Aktualisieren des Blips
local function updateBlip()
    -- Alten Blip entfernen
    if routeBlip and DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)
    end

    if currentRoute and #currentRoute > 0 and currentDeliveryIndex <= #currentRoute then
        local target = currentRoute[currentDeliveryIndex]
        routeBlip = AddBlipForCoord(target.location.x, target.location.y, target.location.z)
        SetBlipRoute(routeBlip, true)
        SetBlipColour(routeBlip, 5) -- Gelb
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Paket-Lieferung")
        EndTextCommandSetBlipName(routeBlip)
    else
        -- Route beendet
        ESX.ShowNotification("Alle Pakete auf dieser Route zugestellt!")
        currentRoute = {}
        currentDeliveryIndex = 0
    end
end

-- Event-Handler zum Starten der Route
RegisterNetEvent('postsystem:startRoute')
AddEventHandler('postsystem:startRoute', function(routeData)
    if #routeData > 0 then
        currentRoute = routeData
        currentDeliveryIndex = 1
        updateBlip()
    else
        ESX.ShowNotification("Keine Lieferungen gefunden.")
    end
end)

-- Event-Handler für erfolgreiche Lieferung
RegisterNetEvent('postsystem:deliverySuccess')
AddEventHandler('postsystem:deliverySuccess', function(deliveredPackageId)
    if currentRoute[currentDeliveryIndex] and currentRoute[currentDeliveryIndex].packageId == deliveredPackageId then
        currentDeliveryIndex = currentDeliveryIndex + 1
        updateBlip()
    end
end)

-- Haupt-Thread für die Lieferlogik
CreateThread(function()
    while true do
        Wait(500) -- Prüfe alle 500ms

        local playerData = ESX.GetPlayerData()
        if playerData.job and playerData.job.name == Config.PostmanJob.JobName then
            -- Nur ausführen, wenn eine Route aktiv ist
            if currentRoute and #currentRoute > 0 and currentDeliveryIndex <= #currentRoute then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local target = currentRoute[currentDeliveryIndex]
                local targetCoords = vector3(target.location.x, target.location.y, target.location.z)
                local distance = #(playerCoords - targetCoords)

                if distance < 3.0 then -- Wenn der Spieler nahe genug am Ziel ist
                    ESX.ShowHelpNotification("Drücke [E], um das Paket zuzustellen.")
                    if IsControlJustReleased(0, 38) then -- E
                        -- Server-Event auslösen, um das Paket als zugestellt zu markieren
                        TriggerServerEvent('postsystem:deliverPackage', target.packageId, target.mailboxId)
                    end
                end
            end
        end
    end
end)

-- Befehl zum Starten der Route (für Testzwecke und als Alternative zur UI)
RegisterCommand('startdelivery', function()
    local playerData = ESX.GetPlayerData()
    if playerData.job and playerData.job.name == Config.PostmanJob.JobName then
        TriggerServerEvent('postsystem:startDeliveryRoute')
    else
        ESX.ShowNotification("Du bist kein Postbote.")
    end
end, false)

-- TODO: UI-Integration, um die Route zu starten.
-- Dies erfordert eine Änderung in ui.html und ui.js, um einen Button für Postboten anzuzeigen.
-- Ich werde dies im nächsten Schritt (Polizei-Inspektion) mit erledigen, da die UI dann sowieso angepasst werden muss.
