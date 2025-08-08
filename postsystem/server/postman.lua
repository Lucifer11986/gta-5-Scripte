ESX = exports["es_extended"]:getSharedObject()

-- Callback: Ausstehende Pakete abrufen
ESX.RegisterServerCallback('postsystem:getPendingPackages', function(source, cb)
    -- Hole alle Pakete mit Status 'pending', sortiert nach Express
    MySQL.Async.fetchAll(
        'SELECT * FROM post_packages WHERE status = "pending" ORDER BY express DESC, creation_timestamp ASC',
        {},
        function(packages)
            cb(packages or {})
        end
    )
end)

-- Event: Lieferroute starten
RegisterNetEvent('postsystem:startDeliveryRoute')
AddEventHandler('postsystem:startDeliveryRoute', function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Hole bis zu 5 ausstehende Pakete und verknüpfe sie mit dem Briefkasten des Empfängers
    local query = [[
        SELECT p.*, m.id as mailbox_id, m.location as mailbox_location
        FROM post_packages p
        JOIN player_mailboxes m ON p.receiver_identifier = m.owner_identifier
        WHERE p.status = "pending"
        ORDER BY p.express DESC, p.creation_timestamp ASC
        LIMIT 5
    ]]

    MySQL.Async.fetchAll(query, {}, function(packages)
        if #packages == 0 then
            TriggerClientEvent('esx:showNotification', src, 'Es gibt keine Pakete zum Ausliefern.')
            return
        end

        local packageIds = {}
        for _, package in ipairs(packages) do
            table.insert(packageIds, package.id)
        end

        -- Aktualisiere den Status der Pakete auf 'in-transit' und weise sie dem Postboten zu
        MySQL.Async.execute(
            'UPDATE post_packages SET status = "in-transit", assigned_postman = @postman WHERE id IN (' .. table.concat(packageIds, ',') .. ')',
            { ['@postman'] = player.identifier },
            function(affectedRows)
                if affectedRows > 0 then
                    -- Sende die Route (mit Briefkasten-Koordinaten) an den Client
                    local routeData = {}
                    for _, package in ipairs(packages) do
                        table.insert(routeData, {
                            packageId = package.id,
                            mailboxId = package.mailbox_id,
                            location = json.decode(package.mailbox_location)
                        })
                    end
                    TriggerClientEvent('postsystem:startRoute', src, routeData)
                    TriggerClientEvent('esx:showNotification', src, 'Route mit ' .. #packages .. ' Paketen gestartet.')
                else
                    TriggerClientEvent('esx:showNotification', src, 'Fehler beim Starten der Route.')
                end
            end
        )
    end)
end)

-- Event: Paket ausliefern
RegisterNetEvent('postsystem:deliverPackage')
AddEventHandler('postsystem:deliverPackage', function(packageId, mailboxId)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Hole das Paket und überprüfe, ob es dem Spieler zugewiesen ist
    MySQL.Async.fetchAll(
        'SELECT * FROM post_packages WHERE id = @id AND assigned_postman = @postman AND status = "in-transit"',
        { ['@id'] = packageId, ['@postman'] = player.identifier },
        function(result)
            local package = result[1]
            if not package then
                TriggerClientEvent('esx:showNotification', src, '❌ Dieses Paket ist nicht für dich oder wurde bereits zugestellt.')
                return
            end

            -- Hole den Briefkasten
            MySQL.Async.fetchAll(
                'SELECT * FROM player_mailboxes WHERE id = @id',
                { ['@id'] = mailboxId },
                function(mailboxes)
                    if #mailboxes == 0 then
                        TriggerClientEvent('esx:showNotification', src, '❌ Briefkasten nicht gefunden.')
                        return
                    end
                    local mailbox = mailboxes[1]
                    local inventory = mailbox.inventory and json.decode(mailbox.inventory) or {}

                    -- Füge das Item zum Briefkasten-Inventar hinzu
                    local itemAdded = false
                    for i, item in ipairs(inventory) do
                        if item.name == package.item_name then
                            inventory[i].count = item.count + package.item_count
                            itemAdded = true
                            break
                        end
                    end
                    if not itemAdded then
                        -- TODO: Get item label from database or config
                        table.insert(inventory, { name = package.item_name, count = package.item_count, label = package.item_name })
                    end

                    -- Aktualisiere das Paket und das Briefkasten-Inventar
                    MySQL.Async.execute('UPDATE post_packages SET status = "delivered" WHERE id = @id', {['@id'] = package.id})
                    MySQL.Async.execute('UPDATE player_mailboxes SET inventory = @inv WHERE id = @id', {['@inv'] = json.encode(inventory), ['@id'] = mailbox.id},
                        function(affectedRows)
                            if affectedRows > 0 then
                                TriggerClientEvent('esx:showNotification', src, '📦 Paket erfolgreich zugestellt!')
                                -- TODO: Belohnung für Postboten etc. hier einfügen

                                -- Benachrichtige den Empfänger
                                local targetPlayer = ESX.GetPlayerFromIdentifier(package.receiver_identifier)
                                if targetPlayer then
                                    TriggerClientEvent('esx:showNotification', targetPlayer.source, 'Dein Paket mit '..package.item_count..'x '..package.item_name..' wurde soeben geliefert!')
                                end

                                -- Sage dem Client, dass die Lieferung erfolgreich war
                                TriggerClientEvent('postsystem:deliverySuccess', src, packageId)
                            end
                        end
                    )
                end
            )
        end
    )
end)
