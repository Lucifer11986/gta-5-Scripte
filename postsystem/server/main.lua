ESX = exports["es_extended"]:getSharedObject()

local playerClothing = {} -- Tabelle zum Speichern der Kleidung für den Postboten-Job

-- Mail senden
RegisterNetEvent("postsystem:sendMail")
AddEventHandler("postsystem:sendMail", function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end
    if not data or not data.station or not data.receiver or not data.message then return end
    local targetPlayer = ESX.GetPlayerFromId(tonumber(data.receiver))
    if not targetPlayer then
        TriggerClientEvent('esx:showNotification', src, "❌ Empfänger nicht online.")
        return
    end
    local receiverIdentifier = targetPlayer.identifier
    MySQL.Async.fetchScalar('SELECT COUNT(id) FROM post_messages WHERE receiver_identifier = @receiver_identifier', {
        ['@receiver_identifier'] = receiverIdentifier
    }, function(count)
        if count and count >= Config.MailboxCapacity then
            TriggerClientEvent("esx:showNotification", src, "❌ Das Postfach des Empfängers ist voll!")
            return
        end
        local stampItem = player.getInventoryItem(Config.StampItem)
        if stampItem.count < 1 then
            TriggerClientEvent("esx:showNotification", src, "❌ Du benötigst eine Briefmarke!")
            return
        end
        local deliveryCost = Config.DeliveryFee
        if data.express then deliveryCost = deliveryCost * Config.ExpressMultiplier end
        if player.getMoney() < deliveryCost then
            TriggerClientEvent("esx:showNotification", src, "❌ Du hast nicht genug Geld!")
            return
        end
        player.removeMoney(deliveryCost)
        player.removeInventoryItem(Config.StampItem, 1)
        TriggerClientEvent("esx:showNotification", src, ("💸 Versandkosten: $%d"):format(deliveryCost))
        local deliveryTime = (data.express and Config.ExpressDeliveryTime or Config.StandardDeliveryTime) * 1000
        SetTimeout(deliveryTime, function()
            MySQL.Async.execute(
                'INSERT INTO post_messages (sender_identifier, sender_name, receiver_identifier, message, express, station) VALUES (@sid, @sname, @rid, @msg, @exp, @stat)',
                {
                    ['@sid'] = player.identifier, ['@sname'] = player.getName(), ['@rid'] = receiverIdentifier,
                    ['@msg'] = data.message, ['@exp'] = data.express or false, ['@stat'] = data.station
                },
                function(affectedRows)
                    if affectedRows > 0 then
                        if targetPlayer then
                            TriggerClientEvent("postsystem:notifyMail", targetPlayer.source, {sender = player.getName(), message = data.message})
                            TriggerClientEvent('esx:showNotification', targetPlayer.source, '📬 Du hast neue Post erhalten!')
                        end
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
    if not player or not mailId then return end
    MySQL.Async.execute('DELETE FROM post_messages WHERE id = @id AND receiver_identifier = @rid',
        {['@id'] = mailId, ['@rid'] = player.identifier},
        function(affectedRows)
            if affectedRows > 0 then TriggerClientEvent("esx:showNotification", src, "🗑️ Nachricht gelöscht!")
            else TriggerClientEvent("esx:showNotification", src, "❌ Fehler: Nachricht nicht gefunden!") end
        end
    )
end)

-- Gruppen-Nachricht senden
RegisterNetEvent("postsystem:sendGroupMail")
AddEventHandler("postsystem:sendGroupMail", function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player or not data.faction or not data.message then return end
    if player.getJob().name ~= data.faction then
        TriggerClientEvent("esx:showNotification", src, "❌ Du bist nicht Teil dieser Gruppe!")
        return
    end
    for _, targetId in ipairs(ESX.GetPlayers()) do
        local targetPlayer = ESX.GetPlayerFromId(targetId)
        if targetPlayer and targetPlayer.getJob().name == data.faction then
            TriggerClientEvent("postsystem:notifyMail", targetId, {
                sender = player.getName(), message = data.message, express = data.express or false, station = data.station
            })
        end
    end
    TriggerClientEvent("esx:showNotification", src, "📨 Gruppen-Nachricht gesendet!")
end)

-- Callback: Mail abrufen
ESX.RegisterServerCallback("postsystem:getMail", function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    if not player then cb({}) return end
    MySQL.Async.fetchAll('SELECT id, sender_name, message, express, station, timestamp FROM post_messages WHERE receiver_identifier = @id ORDER BY timestamp DESC',
        {['@id'] = player.identifier},
        function(result)
            local mails = {}
            if result then
                for _, mail in ipairs(result) do
                    table.insert(mails, {
                        id = mail.id, sender = mail.sender_name, message = mail.message,
                        express = mail.express, station = mail.station, timestamp = mail.timestamp
                    })
                end
            end
            cb(mails)
        end
    )
end)

-- Callbacks für UI
ESX.RegisterServerCallback("postsystem:getStations", function(source, cb) cb(Config.PostStations) end)
ESX.RegisterServerCallback("postsystem:getPlayers", function(source, cb)
    local players = {}
    for _, p_id in ipairs(ESX.GetPlayers()) do
        local p = ESX.GetPlayerFromId(p_id)
        if p then table.insert(players, { id = p.source, name = p.getName() }) end
    end
    cb(players)
end)
ESX.RegisterServerCallback("postsystem:getFactions", function(source, cb) cb(Config.Factions or {}) end)
ESX.RegisterServerCallback('postsystem:getInventory', function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    if not player then cb({}) return end
    local inventory = {}
    if player.inventory then
        for _, item in ipairs(player.inventory) do
            if item.count > 0 and item.type == 'item' and item.name ~= 'cardboard_box' then
                table.insert(inventory, item)
            end
        end
    end
    cb(inventory)
end)

-- Paket senden
RegisterNetEvent('postsystem:sendPackage')
AddEventHandler('postsystem:sendPackage', function(data)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player or not data or not data.receiver or not data.itemName or not data.itemCount then return end
    local targetPlayer = ESX.GetPlayerFromId(tonumber(data.receiver))
    if not targetPlayer then TriggerClientEvent('esx:showNotification', src, '❌ Empfänger nicht online.'); return end
    local receiverIdentifier = targetPlayer.identifier
    local itemCount = tonumber(data.itemCount)
    if not itemCount or itemCount <= 0 then TriggerClientEvent('esx:showNotification', src, '❌ Ungültige Artikelanzahl.'); return end
    if player.getInventoryItem('cardboard_box').count < 1 then TriggerClientEvent('esx:showNotification', src, '❌ Du hast keinen Karton.'); return end
    if player.getInventoryItem(data.itemName).count < itemCount then TriggerClientEvent('esx:showNotification', src, '❌ Du hast nicht genügend von diesem Gegenstand.'); return end

    player.removeInventoryItem('cardboard_box', 1)
    player.removeInventoryItem(data.itemName, itemCount)
    MySQL.Async.execute(
        'INSERT INTO post_packages (sender_identifier, receiver_identifier, item_name, item_count, express) VALUES (@s, @r, @i, @c, @e)',
        {['@s'] = player.identifier, ['@r'] = receiverIdentifier, ['@i'] = data.itemName, ['@c'] = itemCount, ['@e'] = data.express or false},
        function(rows)
            if rows > 0 then TriggerClientEvent('esx:showNotification', src, '📦 Paket wurde erfolgreich für den Versand aufgegeben!')
            else
                TriggerClientEvent('esx:showNotification', src, '❌ Fehler beim Erstellen des Pakets.')
                player.addInventoryItem('cardboard_box', 1)
                player.addInventoryItem(data.itemName, itemCount)
            end
        end
    )
end)

-- Briefkasten-System
RegisterNetEvent('esx:useItem')
AddEventHandler('esx:useItem', function(item)
    if item.name == Config.MailboxItem then
        TriggerClientEvent('postsystem:startMailboxPlacement', source)
    end
end)

RegisterNetEvent('postsystem:placeMailbox')
AddEventHandler('postsystem:placeMailbox', function(location)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end
    if player.getInventoryItem(Config.MailboxItem).count < 1 then TriggerClientEvent('esx:showNotification', src, '❌ Du besitzt keinen Briefkasten mehr.'); return end

    player.removeInventoryItem(Config.MailboxItem, 1)
    MySQL.Async.execute(
        'INSERT INTO player_mailboxes (owner_identifier, location) VALUES (@owner, @location)',
        {['@owner'] = player.identifier, ['@location'] = json.encode(location)},
        function(rows)
            if rows > 0 then
                TriggerClientEvent('esx:showNotification', src, '✅ Briefkasten erfolgreich platziert!')
                -- Send new ID and owner to clients
                local newMailboxData = {id = rows, location = location, owner_identifier = player.identifier}
                TriggerClientEvent('postsystem:spawnNewMailbox', -1, newMailboxData)
            else
                TriggerClientEvent('esx:showNotification', src, '❌ Fehler beim Platzieren des Briefkastens.')
                player.addInventoryItem(Config.MailboxItem, 1)
            end
        end
    )
end)

ESX.RegisterServerCallback('postsystem:getPlacedMailboxes', function(source, cb)
    MySQL.Async.fetchAll('SELECT id, location, owner_identifier FROM player_mailboxes', {}, function(result)
        local mailboxes = {}
        if result then
            for _, box in ipairs(result) do
                table.insert(mailboxes, {id = box.id, location = json.decode(box.location), owner_identifier = box.owner_identifier})
            end
        end
        cb(mailboxes)
    end)
end)

-- Job-Funktionen (bleiben vorerst unverändert)
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

RegisterServerEvent("postsystem:quitPostmanJob")
AddEventHandler("postsystem:quitPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end
    player.setJob(Config.DefaultJob.JobName, Config.DefaultJob.Grade)
    TriggerClientEvent("postsystem:restoreNormalClothing", src)
    TriggerClientEvent("esx:showNotification", src, "🚪 Du hast den Postboten-Job beendet.")
end)
