-- server/art_trade.lua
ESX = nil
QBCore = nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

-- Lade Kunstwerke aus der Datenbank
function GetArtworks(cb)
    MySQL.Async.fetchAll('SELECT * FROM artworks', {}, function(artworks)
        cb(artworks)
    end)
end

-- Kunstwerk kaufen oder verkaufen
RegisterServerEvent('art_trade:tradeArt')
AddEventHandler('art_trade:tradeArt', function(action, artworkId)
    local xPlayer = ESX and ESX.GetPlayerFromId(source) or QBCore.Functions.GetPlayer(source)

    if action == 'buy' then
        MySQL.Async.fetchAll('SELECT * FROM artworks WHERE id = @id', {['@id'] = artworkId}, function(result)
            if result[1] then
                local artwork = result[1]
                local price = artwork.price

                -- Rabatt für bestimmte Jobs
                if (ESX and xPlayer.job.name == 'kunsthaendler') or (QBCore and xPlayer.PlayerData.job.name == 'kunsthaendler') then
                    price = math.floor(price * 0.8) -- 20% Rabatt
                end

                if xPlayer.getMoney() >= price then
                    xPlayer.removeMoney(price)

                    MySQL.Async.execute('INSERT INTO player_artworks (identifier, artwork_id) VALUES (@identifier, @artwork_id)', {
                        ['@identifier'] = xPlayer.identifier or xPlayer.PlayerData.citizenid,
                        ['@artwork_id'] = artwork.id
                    })

                    TriggerClientEvent('esx:showNotification', source, 'Du hast ~g~' .. artwork.label .. '~s~ für ~g~$' .. price .. '~s~ gekauft!')
                else
                    TriggerClientEvent('esx:showNotification', source, '~r~Du hast nicht genug Geld!')
                end
            end
        end)
    elseif action == 'sell' then
        MySQL.Async.fetchAll('SELECT * FROM player_artworks WHERE identifier = @identifier AND artwork_id = @artwork_id', {
            ['@identifier'] = xPlayer.identifier or xPlayer.PlayerData.citizenid,
            ['@artwork_id'] = artworkId
        }, function(result)
            if result[1] then
                MySQL.Async.fetchAll('SELECT price FROM artworks WHERE id = @id', {['@id'] = artworkId}, function(artworkResult)
                    if artworkResult[1] then
                        local price = artworkResult[1].price * 0.5 -- 50% Verkaufspreis

                        MySQL.Async.execute('DELETE FROM player_artworks WHERE id = @id', {
                            ['@id'] = result[1].id
                        })

                        xPlayer.addMoney(price)
                        TriggerClientEvent('esx:showNotification', source, 'Du hast ~g~$' .. price .. '~s~ für dein Kunstwerk erhalten!')
                    end
                end)
            else
                TriggerClientEvent('esx:showNotification', source, '~r~Du besitzt dieses Kunstwerk nicht!')
            end
        end)
    end
end)