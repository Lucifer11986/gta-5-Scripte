-- Lade Kunstwerke aus der Datenbank
function GetArtworks(cb)
    MySQL.Async.fetchAll('SELECT * FROM artworks', {}, function(artworks)
        cb(artworks)
    end)
end

local function sendArtworksToClient(player)
    GetArtworks(function(artworks)
        TriggerClientEvent('art_trade:setArtworks', player, artworks)
    end)
end

-- Lade Kunstwerke, wenn der Spieler dem Server beitritt
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    sendArtworksToClient(playerId)
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    sendArtworksToClient(source)
end)

-- Kunstwerk kaufen oder verkaufen
RegisterServerEvent('art_trade:tradeArt')
AddEventHandler('art_trade:tradeArt', function(action, id)
    local src = source
    local xPlayer = GetPlayer(src)
    if not xPlayer then return end

    local playerIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid

    if action == 'buy' then
        local artworkId = id
        MySQL.Async.fetchAll('SELECT * FROM artworks WHERE id = @id', {['@id'] = artworkId}, function(result)
            if result[1] then
                local artwork = result[1]
                local price = artwork.price

                if (Config.Framework == 'esx' and xPlayer.job.name == Config.DiscountJob) or (Config.Framework == 'qb' and xPlayer.PlayerData.job.name == Config.DiscountJob) then
                    price = math.floor(price * Config.DiscountAmount)
                end

                if xPlayer.getMoney() >= price then
                    xPlayer.removeMoney(price)

                    MySQL.Async.execute('INSERT INTO player_artworks (identifier, artwork_id) VALUES (@identifier, @artwork_id)', {
                        ['@identifier'] = playerIdentifier,
                        ['@artwork_id'] = artwork.id
                    })

                    ShowNotification(src, 'Du hast ~g~' .. artwork.label .. '~s~ für ~g~$' .. price .. '~s~ gekauft!')
                else
                    ShowNotification(src, '~r~Du hast nicht genug Geld!')
                end
            end
        end)
    elseif action == 'sell' then
        local playerArtworkId = id

        MySQL.Async.fetchAll('SELECT * FROM player_artworks WHERE id = @id AND identifier = @identifier', {
            ['@id'] = playerArtworkId,
            ['@identifier'] = playerIdentifier
        }, function(playerArtworkResult)
            if playerArtworkResult[1] then
                local artworkToSell = playerArtworkResult[1]

                MySQL.Async.fetchAll('SELECT price, label FROM artworks WHERE id = @id', {['@id'] = artworkToSell.artwork_id}, function(artworkDetails)
                    if artworkDetails[1] then
                        local price = artworkDetails[1].price * Config.SellMultiplier
                        local label = artworkDetails[1].label

                        MySQL.Async.execute('DELETE FROM player_artworks WHERE id = @id', {
                            ['@id'] = artworkToSell.id
                        }, function(rowsChanged)
                            if rowsChanged > 0 then
                                xPlayer.addMoney(price)
                                ShowNotification(src, 'Du hast ~g~' .. label .. '~s~ für ~g~$' .. price .. '~s~ verkauft!')
                            else
                                ShowNotification(src, '~r~Fehler beim Verkaufen.')
                            end
                        end)
                    else
                        ShowNotification(src, '~r~Kunstwerk nicht in der Datenbank gefunden.')
                    end
                end)
            else
                ShowNotification(src, '~r~Du besitzt dieses Kunstwerk nicht oder es ist ein Fehler aufgetreten.')
            end
        end)
    end
end)

-- Event, um die Kunstwerke eines Spielers abzurufen
RegisterServerEvent('art_trade:getPlayerArtworks')
AddEventHandler('art_trade:getPlayerArtworks', function()
    local src = source
    local xPlayer = GetPlayer(src)
    if not xPlayer then return end

    local playerIdentifier = xPlayer.identifier or xPlayer.PlayerData.citizenid

    MySQL.Async.fetchAll(
        'SELECT pa.id as player_artwork_id, a.* FROM player_artworks pa JOIN artworks a ON pa.artwork_id = a.id WHERE pa.identifier = @identifier',
        { ['@identifier'] = playerIdentifier },
        function(playerArtworks)
            TriggerClientEvent('art_trade:setPlayerArtworks', source, playerArtworks)
        end
    )
end)
