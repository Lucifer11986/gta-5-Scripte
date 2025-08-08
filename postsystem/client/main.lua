-- Importiere die Config-Tabelle
Config = Config or {}

ESX = exports["es_extended"]:getSharedObject()

local isUIOpen = false
local eventsRegistered = false -- Flag, um zu überprüfen, ob Events bereits registriert sind

-- NPC-Modell
local npcModel = "s_m_m_postal_01"

-- Funktion zum Spawnen der NPCs
local function spawnNPCs()
    for _, station in ipairs(Config.PostStations) do
        RequestModel(npcModel)
        while not HasModelLoaded(npcModel) do
            Citizen.Wait(10)
        end

        -- Spawne den NPC mit der korrekten Rotation (Heading)
        local npc = CreatePed(4, npcModel, station.x, station.y, station.z, station.heading, false, true)
        SetEntityHeading(npc, station.heading) -- Setze die Rotation des NPCs
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
    end
end

-- Funktion zur Überprüfung, ob der Spieler in der Nähe einer Poststation ist
local function isNearPostStation()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, station in ipairs(Config.PostStations) do
        local stationCoords = vector3(station.x, station.y, station.z)
        local distance = #(playerCoords - stationCoords)
        if distance < 1.5 then
            return true
        end
    end
    return false
end

-- Funktion zum Anzeigen von 3D-Text
local function drawText3D(coords, text)
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

-- Funktion zum Erstellen von Blips für Poststationen
local function createPostStationBlips()
    for _, station in ipairs(Config.PostStations) do
        local blip = AddBlipForCoord(station.x, station.y, station.z)
        SetBlipSprite(blip, Config.BlipSettings.sprite)
        SetBlipColour(blip, Config.BlipSettings.color)
        SetBlipScale(blip, Config.BlipSettings.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- Funktion zur Registrierung von Events
local function registerEvents()
    if eventsRegistered then return end -- Beende die Funktion, wenn Events bereits registriert sind

    -- Benachrichtigung über neue Mail
    RegisterNetEvent("postsystem:notifyMail")
    AddEventHandler("postsystem:notifyMail", function(mailEntry)
        if mailEntry and mailEntry.sender then
            if mailEntry.express then
                ESX.ShowNotification(("📩 ~y~Express-Brief von ~w~%s erhalten!"):format(mailEntry.sender))
            else
                ESX.ShowNotification(("📩 Neuer Brief von %s erhalten!"):format(mailEntry.sender))
            end
        else
            print("❌ Fehler: Ungültige Mail-Benachrichtigung erhalten!", json.encode(mailEntry))
        end
    end)

    -- Postsystem öffnen
    RegisterCommand("openMail", function()
        if isUIOpen then return end

        -- Überprüfe, ob der Spieler in der Nähe einer Poststation ist
        if not isNearPostStation() then
            ESX.ShowNotification("❌ Du bist nicht in der Nähe einer Poststation!")
            return
        end

        ESX.TriggerServerCallback("postsystem:getMail", function(receivedMessages)
            if not receivedMessages then receivedMessages = {} end

            ESX.TriggerServerCallback("postsystem:getStations", function(stations)
                if not stations then stations = {} end

                ESX.TriggerServerCallback("postsystem:getPlayers", function(players)
                    if not players then players = {} end

                    ESX.TriggerServerCallback("postsystem:getFactions", function(factions)
                        if not factions then factions = {} end

                        SetNuiFocus(true, true)
                        SendNUIMessage({
                            action = "openUI",
                            stations = stations,
                            players = players,
                            factions = factions,
                            receivedMessages = receivedMessages
                        })
                        isUIOpen = true
                        print("📬 Postsystem geöffnet")
                    end)
                end)
            end)
        end)
    end, false)

    -- UI schließen
    RegisterNUICallback("closeUI", function(data, cb)
        SetNuiFocus(false, false)
        isUIOpen = false
        cb("ok")
        print("📬 Postsystem geschlossen")
    end)

    -- Mail senden
    RegisterNUICallback("sendMail", function(data, cb)
        if data and data.station and data.receiver and data.message then
            -- Konvertiere receiver in eine Zahl
            data.receiver = tonumber(data.receiver)
            
            -- Debug-Ausgabe
            print("📨 Sende Mail an Server...", json.encode(data))
            
            -- Überprüfe, ob Express-Versand aktiviert ist
            local isExpress = data.express or false
            local deliveryTime = isExpress and Config.ExpressDeliveryTime or Config.StandardDeliveryTime
            
            -- Zeige eine Benachrichtigung an
            ESX.ShowNotification(("📩 Deine Nachricht wurde versendet! Lieferzeit: %d Sekunden"):format(deliveryTime))
            
            -- Sende Daten an den Server
            TriggerServerEvent("postsystem:sendMail", data)
            cb("ok")
        else
            print("❌ Fehler: Ungültige Mail-Daten beim Senden!", json.encode(data))
            ESX.ShowNotification("❌ Fehler: Ungültige Mail-Daten!")
            cb("error")
        end
    end)

    -- Gruppen-Nachricht senden
    RegisterNUICallback("sendGroupMail", function(data, cb)
        if data and data.station and data.faction and data.message then
            -- Debug-Ausgabe
            print("📨 Sende Gruppen-Nachricht an Server...", json.encode(data))
            
            -- Überprüfe, ob Express-Versand aktiviert ist
            local isExpress = data.express or false
            local deliveryTime = isExpress and Config.ExpressDeliveryTime or Config.StandardDeliveryTime
            
            -- Zeige eine Benachrichtigung an
            ESX.ShowNotification(("📩 Deine Gruppen-Nachricht wurde versendet! Lieferzeit: %d Sekunden"):format(deliveryTime))
            
            -- Sende Daten an den Server
            TriggerServerEvent("postsystem:sendGroupMail", data)
            cb("ok")
        else
            print("❌ Fehler: Ungültige Gruppen-Nachrichtendaten beim Senden!", json.encode(data))
            ESX.ShowNotification("❌ Fehler: Ungültige Gruppen-Nachrichtendaten!")
            cb("error")
        end
    end)

    -- Mail löschen
    RegisterNUICallback("deleteMail", function(data, cb)
        if data and data.id then
            print("🗑️ Lösche Mail mit ID:", data.id)
            TriggerServerEvent("postsystem:deleteMail", data.id)
            cb("ok")
        else
            print("❌ Fehler: Ungültige Mail-ID beim Löschen!", json.encode(data))
            ESX.ShowNotification("❌ Fehler: Ungültige Mail-ID!")
            cb("error")
        end
    end)

    -- Antwort auf eine Nachricht
    RegisterNUICallback("replyMail", function(data, cb)
        if data and data.sender then
            -- Öffne das Postsystem mit vorausgefülltem Empfänger und Nachricht
            SendNUIMessage({
                action = "openUI",
                replyTo = data.sender, -- Empfänger vorausfüllen
                replyMessage = "RE: " .. data.message -- Nachricht vorausfüllen
            })
            cb("ok")
        else
            cb("error")
        end
    end)

    -- Tastenzuordnung
    RegisterKeyMapping("openMail", "Postsystem öffnen", "keyboard", "E")

    eventsRegistered = true -- Setze das Flag auf true, um zu signalisieren, dass Events registriert sind
end

-- Erstelle Blips und NPCs beim Start
CreateThread(function()
    createPostStationBlips()
    spawnNPCs()
end)

-- Registriere Events beim Start
registerEvents()

-- Überprüfe kontinuierlich, ob der Spieler in der Nähe einer Poststation ist und zeige die Meldung an
CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local isNear = false

        for _, station in ipairs(Config.PostStations) do
            local stationCoords = vector3(station.x, station.y, station.z)
            local distance = #(playerCoords - stationCoords)
            if distance < 1.5 then
                isNear = true
                drawText3D(stationCoords, "~g~Drücke ~w~[~b~E~w~], um die Poststation zu öffnen")
                break
            end
        end

        if isNear and IsControlJustReleased(0, 38) then -- 38 ist der Keycode für die E-Taste
            ExecuteCommand("openMail")
        end
    end
end)