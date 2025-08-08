ESX = exports["es_extended"]:getSharedObject()

-- Callback: Briefkasten-Inventar abrufen
ESX.RegisterServerCallback('postsystem:getMailboxInventory', function(source, cb, mailboxId)
    local player = ESX.GetPlayerFromId(source)
    if not player then cb(nil) return end

    -- Hole den Briefkasten und überprüfe den Besitzer
    MySQL.Async.fetchAll(
        'SELECT * FROM player_mailboxes WHERE id = @id AND owner_identifier = @owner',
        {
            ['@id'] = mailboxId,
            ['@owner'] = player.identifier
        },
        function(result)
            if #result > 0 then
                local mailbox = result[1]
                local inventory = mailbox.inventory and json.decode(mailbox.inventory) or {}
                cb(inventory)
            else
                cb(nil) -- Entweder nicht der Besitzer oder Briefkasten existiert nicht
            end
        end
    )
end)

-- Event: Item aus dem Briefkasten nehmen
RegisterNetEvent('postsystem:takeFromMailbox')
AddEventHandler('postsystem:takeFromMailbox', function(mailboxId, itemName)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Hole den Briefkasten und überprüfe den Besitzer
    MySQL.Async.fetchAll(
        'SELECT * FROM player_mailboxes WHERE id = @id AND owner_identifier = @owner',
        {
            ['@id'] = mailboxId,
            ['@owner'] = player.identifier
        },
        function(result)
            if #result > 0 then
                local mailbox = result[1]
                local inventory = mailbox.inventory and json.decode(mailbox.inventory) or {}
                local newInventory = {}
                local itemTaken = false
                local itemCount = 0
                local itemLabel = ''

                -- Finde das Item und entferne es aus dem Inventar
                for i, item in ipairs(inventory) do
                    if item.name == itemName and not itemTaken then
                        itemCount = item.count
                        itemLabel = item.label
                        itemTaken = true
                        -- Alle anderen Items behalten
                    else
                        table.insert(newInventory, item)
                    end
                end

                if itemTaken then
                    -- Aktualisiere das Briefkasten-Inventar in der DB
                    MySQL.Async.execute(
                        'UPDATE player_mailboxes SET inventory = @inv WHERE id = @id',
                        { ['@inv'] = json.encode(newInventory), ['@id'] = mailbox.id },
                        function(affectedRows)
                            if affectedRows > 0 then
                                -- Gib dem Spieler das Item
                                player.addInventoryItem(itemName, itemCount)
                                TriggerClientEvent('esx:showNotification', src, 'Du hast ' .. itemCount .. 'x ' .. itemLabel .. ' aus deinem Briefkasten genommen.')
                                -- Sende das aktualisierte Inventar zurück an den Client
                                TriggerClientEvent('postsystem:updateMailboxInventory', src, newInventory)
                            end
                        end
                    )
                end
            end
        end
    )
end)
