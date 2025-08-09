ESX = exports["es_extended"]:getSharedObject()

-- Callback: Pakete zur Inspektion abrufen
ESX.RegisterServerCallback('postsystem:getPackagesForInspection', function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    if not player or player.job.name ~= 'police' then
        cb({}) -- Nur für die Polizei
        return
    end

    MySQL.Async.fetchAll(
        'SELECT id, sender_name, item_name, item_count, express FROM post_packages WHERE status = "pending" ORDER BY creation_timestamp DESC',
        {},
        function(packages)
            cb(packages or {})
        end
    )
end)

-- Event: Paket beschlagnahmen
RegisterNetEvent('postsystem:confiscatePackage')
AddEventHandler('postsystem:confiscatePackage', function(packageId)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player or player.job.name ~= 'police' then return end

    -- Hole Paketdetails, bevor es gelöscht wird
    MySQL.Async.fetchAll(
        'SELECT * FROM post_packages WHERE id = @id AND status = "pending"',
        { ['@id'] = packageId },
        function(result)
            local package = result[1]
            if not package then
                TriggerClientEvent('esx:showNotification', src, '❌ Paket nicht gefunden oder bereits in Zustellung.')
                return
            end

            -- Lösche das Paket aus der Datenbank
            MySQL.Async.execute(
                'DELETE FROM post_packages WHERE id = @id',
                { ['@id'] = packageId },
                function(affectedRows)
                    if affectedRows > 0 then
                        -- Gib dem Polizisten das Item
                        player.addInventoryItem(package.item_name, package.item_count)

                        TriggerClientEvent('esx:showNotification', src, '📦 Paket (' .. package.item_count .. 'x ' .. package.item_name .. ') wurde beschlagnahmt.')

                        -- Logge die Aktion
                        print(('[postsystem] Police Confiscation: Officer %s (ID: %s) confiscated package #%s containing %s x%s.'):format(player.getName(), player.identifier, packageId, package.item_name, package.item_count))
                    else
                        TriggerClientEvent('esx:showNotification', src, '❌ Fehler beim Beschlagnahmen des Pakets.')
                    end
                end
            )
        end
    )
end)
