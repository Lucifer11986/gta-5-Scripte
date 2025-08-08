ESX = exports["es_extended"]:getSharedObject()

local mailData = {}
local playerClothing = {} -- Tabelle zum Speichern der Kleidung

-- Mail senden
RegisterNetEvent("postsystem:sendMail")
AddEventHandler("postsystem:sendMail", function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then 
        print("❌ Fehler: Absender nicht gefunden!")
        return 
    end

    -- Debugging: Zeige die empfangenen Daten an
    print("Daten beim Senden der Mail:", json.encode(data))

    -- Überprüfe die Daten
    if not data or not data.station or not data.receiver or not data.message then
        print("❌ Fehler: Ungültige Nachrichtendaten erhalten!")
        if data then
            print("Daten:", json.encode(data))
        else
            print("Daten sind nil")
        end
        return
    end

    local targetId = tonumber(data.receiver)
    if not targetId then
        print("❌ Fehler: Ungültige Empfänger-ID!")
        return
    end

    local receiver = ESX.GetPlayerFromId(targetId)
    if not receiver then
        print("❌ Fehler: Empfänger nicht gefunden! ID:", targetId)
        return
    end

    -- Überprüfe, ob der Empfänger noch Platz im Postfach hat
    if mailData[targetId] and #mailData[targetId] >= Config.MailboxCapacity then
        TriggerClientEvent("esx:showNotification", src, "❌ Das Postfach des Empfängers ist voll!")
        return
    end

    -- Überprüfe, ob der Spieler eine Briefmarke hat
    local stampItem = player.getInventoryItem(Config.StampItem)
    if stampItem.count < 1 then
        TriggerClientEvent("esx:showNotification", src, "❌ Du benötigst eine Briefmarke, um diese Nachricht zu versenden!")
        return
    end

    -- Entferne eine Briefmarke aus dem Inventar des Spielers
    player.removeInventoryItem(Config.StampItem, 1)

    -- Berechne die Versandkosten
    local deliveryCost = Config.DeliveryFee
    if data.express then
        deliveryCost = deliveryCost * Config.ExpressMultiplier
    end

    -- Überprüfe, ob der Spieler genug Geld hat
    if player.getMoney() < deliveryCost then
        TriggerClientEvent("esx:showNotification", src, "❌ Du hast nicht genug Geld, um diese Nachricht zu versenden!")
        return
    end

    -- Ziehe das Geld vom Konto des Spielers ab
    player.removeMoney(deliveryCost)
    TriggerClientEvent("esx:showNotification", src, ("💸 Versandkosten in Höhe von $%d wurden von deinem Konto abgebucht."):format(deliveryCost))

    -- Erstelle die Mail
    local mailId = os.time() .. math.random(1000, 9999)
    local mailEntry = {
        id = mailId,
        sender = player.getName(),
        message = data.message,
        express = data.express or false,
        station = data.station -- Speichere die Poststation, an die die Nachricht gesendet wurde
    }

    -- Bestimme die Lieferzeit
    local deliveryTime = mailEntry.express and Config.ExpressDeliveryTime or Config.StandardDeliveryTime

    -- Speichere die Mail erst nach der Lieferzeit
    SetTimeout(deliveryTime * 1000, function()
        if not mailData[targetId] then
            mailData[targetId] = {}
        end
        table.insert(mailData[targetId], mailEntry)

        -- Informiere den Empfänger
        TriggerClientEvent("postsystem:notifyMail", targetId, mailEntry)
    end)

    print(("📨 Nachricht von %s an %s gesendet (Express: %s, Lieferzeit: %d Sekunden, Kosten: $%d)"):format(
        player.getName(), receiver.getName(), mailEntry.express and "Ja" or "Nein", deliveryTime, deliveryCost
    ))
end)

-- Mail löschen
RegisterNetEvent("postsystem:deleteMail")
AddEventHandler("postsystem:deleteMail", function(mailId)
    local playerId = source
    if not mailId then
        print("❌ Fehler: Keine Mail-ID angegeben!")
        return
    end

    if not mailData[playerId] then
        print("ℹ️ Keine Mails für Spieler %s gefunden", playerId)
        return
    end

    for i, mail in ipairs(mailData[playerId]) do
        if mail.id == mailId then
            table.remove(mailData[playerId], i)
            print(("🗑️ Nachricht %s von Spieler %s gelöscht"):format(mailId, playerId))
            TriggerClientEvent("esx:showNotification", playerId, "🗑️ Nachricht gelöscht!")
            return
        end
    end

    print("❌ Fehler: Nachricht nicht gefunden!")
    TriggerClientEvent("esx:showNotification", playerId, "❌ Fehler: Nachricht nicht gefunden!")
end)

-- Gruppen-Nachricht senden
RegisterNetEvent("postsystem:sendGroupMail")
AddEventHandler("postsystem:sendGroupMail", function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Überprüfe, ob der Spieler Teil der Fraktion/Group ist
    local playerJob = player.getJob()
    if playerJob.name ~= data.faction then
        TriggerClientEvent("esx:showNotification", src, "❌ Du bist nicht Teil dieser Gruppe!")
        return
    end

    -- Sende die Nachricht an alle Mitglieder der Fraktion/Group
    local players = ESX.GetPlayers()
    for _, targetId in ipairs(players) do
        local targetPlayer = ESX.GetPlayerFromId(targetId)
        if targetPlayer and targetPlayer.getJob().name == data.faction then
            TriggerClientEvent("postsystem:notifyMail", targetId, {
                sender = player.getName(),
                message = data.message,
                express = data.express or false,
                station = data.station
            })
        end
    end

    -- Benachrichtige den Absender
    TriggerClientEvent("esx:showNotification", src, "📨 Gruppen-Nachricht gesendet!")
end)

-- Callback: Mail abrufen
ESX.RegisterServerCallback("postsystem:getMail", function(source, cb)
    local playerId = source
    local player = ESX.GetPlayerFromId(playerId)
    if not player then
        cb({})
        return
    end

    -- Überprüfe, ob der Spieler in der Nähe der richtigen Poststation ist
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
    local isNearCorrectStation = false
    for _, station in ipairs(Config.PostStations) do
        local stationCoords = vector3(station.x, station.y, station.z)
        local distance = #(playerCoords - stationCoords)
        if distance < 1.5 then
            isNearCorrectStation = true
            break
        end
    end

    if not isNearCorrectStation then
        TriggerClientEvent("esx:showNotification", playerId, "❌ Du bist nicht in der Nähe der richtigen Poststation!")
        cb({})
        return
    end

    -- Gib die Mails des Spielers zurück
    cb(mailData[playerId] or {})
end)

-- Callback: Poststationen abrufen
ESX.RegisterServerCallback("postsystem:getStations", function(source, cb)
    local stations = {
        { name = "Paleto Post Office" },
        { name = "Sandy Post Office" },
        { name = "City Post Office" }
    }
    cb(stations)
end)

-- Callback: Spielerliste abrufen
ESX.RegisterServerCallback("postsystem:getPlayers", function(source, cb)
    local players = {}

    for _, player in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(player)
        if xPlayer then
            table.insert(players, { id = player, name = xPlayer.getName() })
        else
            print("⚠️ Warnung: Spieler mit ID", player, "nicht gefunden.")
        end
    end

    cb(players)
end)

-- Callback: Fraktionen/Gruppen abrufen
ESX.RegisterServerCallback("postsystem:getFactions", function(source, cb)
    -- Debugging: Zeige die Fraktionsdaten an
    print("Fraktionsdaten werden gesendet:", json.encode(Config.Factions))
    
    -- Gib die Fraktionsdaten zurück
    cb(Config.Factions)
end)

-- Funktion zum Annehmen des Postboten-Jobs
RegisterServerEvent("postsystem:acceptPostmanJob")
AddEventHandler("postsystem:acceptPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Speichere die aktuelle Kleidung des Spielers
    TriggerClientEvent("postsystem:saveCurrentClothing", src)

    -- Setze den Job des Spielers auf Postbote
    player.setJob(Config.PostmanJob.JobName, 0) -- 0 ist der Rang (z. B. Anfänger)

    -- Uniform anziehen
    TriggerClientEvent("postsystem:setPostmanUniform", src)

    -- Benachrichtigung
    TriggerClientEvent("esx:showNotification", src, "✅ Du bist jetzt ein Postbote!")
end)

-- Funktion zum Beenden des Postboten-Jobs
RegisterServerEvent("postsystem:quitPostmanJob")
AddEventHandler("postsystem:quitPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Setze den Job des Spielers zurück auf den Standard-Job
    player.setJob(Config.DefaultJob.JobName, Config.DefaultJob.Grade)

    -- Normale Kleidung wiederherstellen
    TriggerClientEvent("postsystem:restoreNormalClothing", src)

    -- Benachrichtigung
    TriggerClientEvent("esx:showNotification", src, "🚪 Du hast den Postboten-Job beendet und deine normale Kleidung angezogen.")
end)

-- Funktion zum Hinzufügen von Geld
function AddMoney(playerId, amount)
    local player = ESX.GetPlayerFromId(playerId)
    if player then
        player.addMoney(amount)
        TriggerClientEvent("esx:showNotification", playerId, "Du hast $" .. amount .. " erhalten!")
    end
end