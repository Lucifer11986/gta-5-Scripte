ESX = exports["es_extended"]:getSharedObject()

local playerClothing = {} -- Tabelle zum Speichern der Kleidung für den Postboten-Job

-- Mail senden
RegisterNetEvent("postsystem:sendMail")
AddEventHandler("postsystem:sendMail", function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then
        print("❌ Fehler: Absender nicht gefunden!")
        return
    end

    if not data or not data.station or not data.receiver or not data.message then
        print("❌ Fehler: Ungültige Nachrichtendaten erhalten!")
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(tonumber(data.receiver))
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, "❌ Empfänger nicht online.")
        return
    end
    local receiverIdentifier = targetPlayer.identifier

    -- Überprüfe, ob der Empfänger noch Platz im Postfach hat
    MySQL.Async.fetchScalar('SELECT COUNT(id) FROM post_messages WHERE receiver_identifier = @receiver_identifier', {
        ['@receiver_identifier'] = receiverIdentifier
    }, function(count)
        if count and count >= Config.MailboxCapacity then
            TriggerClientEvent("esx:showNotification", src, "❌ Das Postfach des Empfängers ist voll!")
            return
        end

        -- Überprüfe, ob der Spieler eine Briefmarke hat
        local stampItem = player.getInventoryItem(Config.StampItem)
        if stampItem.count < 1 then
            TriggerClientEvent("esx:showNotification", src, "❌ Du benötigst eine Briefmarke, um diese Nachricht zu versenden!")
            return
        end

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

        -- Ziehe das Geld und die Briefmarke vom Spieler ab
        player.removeMoney(deliveryCost)
        player.removeInventoryItem(Config.StampItem, 1)
        TriggerClientEvent("esx:showNotification", src, ("💸 Versandkosten in Höhe von $%d wurden von deinem Konto abgebucht."):format(deliveryCost))

        -- Bestimme die Lieferzeit
        local deliveryTime = (data.express and Config.ExpressDeliveryTime or Config.StandardDeliveryTime) * 1000

        -- Speichere die Mail erst nach der Lieferzeit
        SetTimeout(deliveryTime, function()
            MySQL.Async.execute(
                'INSERT INTO post_messages (sender_identifier, sender_name, receiver_identifier, message, express, station) VALUES (@sender_identifier, @sender_name, @receiver_identifier, @message, @express, @station)',
                {
                    ['@sender_identifier'] = player.identifier,
                    ['@sender_name'] = player.getName(),
                    ['@receiver_identifier'] = receiverIdentifier,
                    ['@message'] = data.message,
                    ['@express'] = data.express or false,
                    ['@station'] = data.station
                },
                function(affectedRows)
                    if affectedRows > 0 then
                        -- Informiere den Empfänger, wenn er online ist
                        if targetPlayer then
                            TriggerClientEvent("postsystem:notifyMail", targetPlayer.source, {
                                sender = player.getName(),
                                message = data.message
                            })
                            TriggerClientEvent('esx:showNotification', targetPlayer.source, '📬 Du hast neue Post erhalten!')
                        end
                        print(("📨 Nachricht von %s an %s in DB gespeichert (Express: %s)"):format(player.getName(), targetPlayer.getName(), data.express and "Ja" or "Nein"))
                    else
                        print("❌ Fehler: Nachricht konnte nicht in der Datenbank gespeichert werden.")
                        -- Hier könnte man dem Spieler das Geld/Item zurückgeben
                    end
                end
            )
        end)
    end)
end)

-- Mail löschen
RegisterNetEvent("postsystem:deleteMail")
AddEventHandler("postsystem:deleteMail", function(mailId)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    if not mailId then
        print("❌ Fehler: Keine Mail-ID angegeben!")
        return
    end

    MySQL.Async.execute(
        'DELETE FROM post_messages WHERE id = @id AND receiver_identifier = @receiver_identifier',
        {
            ['@id'] = mailId,
            ['@receiver_identifier'] = player.identifier
        },
        function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent("esx:showNotification", src, "🗑️ Nachricht gelöscht!")
            else
                TriggerClientEvent("esx:showNotification", src, "❌ Fehler: Nachricht nicht gefunden!")
            end
        end
    )
end)

-- Gruppen-Nachricht senden (bleibt unverändert, da es nur eine Benachrichtigung ist)
RegisterNetEvent("postsystem:sendGroupMail")
AddEventHandler("postsystem:sendGroupMail", function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    local playerJob = player.getJob()
    if playerJob.name ~= data.faction then
        TriggerClientEvent("esx:showNotification", src, "❌ Du bist nicht Teil dieser Gruppe!")
        return
    end

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

    TriggerClientEvent("esx:showNotification", src, "📨 Gruppen-Nachricht gesendet!")
end)

-- Callback: Mail abrufen
ESX.RegisterServerCallback("postsystem:getMail", function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    if not player then
        cb({})
        return
    end

    MySQL.Async.fetchAll(
        'SELECT id, sender_name, message, express, station, timestamp FROM post_messages WHERE receiver_identifier = @identifier ORDER BY timestamp DESC',
        {
            ['@identifier'] = player.identifier
        },
        function(result)
            local mails = {}
            if result then
                for i=1, #result, 1 do
                    local mail = result[i]
                    table.insert(mails, {
                        id = mail.id,
                        sender = mail.sender_name, -- Client erwartet 'sender'
                        message = mail.message,
                        express = mail.express,
                        station = mail.station,
                        timestamp = mail.timestamp
                    })
                end
            end
            cb(mails)
        end
    )
end)

-- Callback: Poststationen abrufen
ESX.RegisterServerCallback("postsystem:getStations", function(source, cb)
    cb(Config.PostStations)
end)

-- Callback: Spielerliste abrufen
ESX.RegisterServerCallback("postsystem:getPlayers", function(source, cb)
    local players = {}
    local plys = ESX.GetPlayers()

    for i=1, #plys, 1 do
        local xPlayer = ESX.GetPlayerFromId(plys[i])
        if xPlayer then
            table.insert(players, { id = xPlayer.source, name = xPlayer.getName() })
        end
    end

    cb(players)
end)

-- Callback: Fraktionen/Gruppen abrufen
ESX.RegisterServerCallback("postsystem:getFactions", function(source, cb)
    cb(Config.Factions or {})
end)

-- Funktion zum Annehmen des Postboten-Jobs
RegisterServerEvent("postsystem:acceptPostmanJob")
AddEventHandler("postsystem:acceptPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    TriggerClientEvent("postsystem:saveCurrentClothing", src)
    player.setJob(Config.PostmanJob.JobName, 0)
    TriggerClientEvent("postsystem:setPostmanUniform", src)
    TriggerClientEvent("esx:showNotification", src, "✅ Du bist jetzt ein Postbote!")
end)

-- Funktion zum Beenden des Postboten-Jobs
RegisterServerEvent("postsystem:quitPostmanJob")
AddEventHandler("postsystem:quitPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    player.setJob(Config.DefaultJob.JobName, Config.DefaultJob.Grade)
    TriggerClientEvent("postsystem:restoreNormalClothing", src)
    TriggerClientEvent("esx:showNotification", src, "🚪 Du hast den Postboten-Job beendet.")
end)

-- Funktion zum Hinzufügen von Geld
function AddMoney(playerId, amount)
    local player = ESX.GetPlayerFromId(playerId)
    if player then
        player.addMoney(amount)
        TriggerClientEvent("esx:showNotification", playerId, "Du hast $" .. amount .. " erhalten!")
    end
end
