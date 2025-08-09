local artworks = {}
local playerArtworks = {}

-- Event handler to receive the list of all available artworks from the server
RegisterNetEvent('art_trade:setArtworks')
AddEventHandler('art_trade:setArtworks', function(result)
    artworks = result
end)

-- Event handler to receive the player's owned artworks from the server
RegisterNetEvent('art_trade:setPlayerArtworks')
AddEventHandler('art_trade:setPlayerArtworks', function(result)
    playerArtworks = result
    OpenSellMenuInternal() -- Now we can open the menu because we have the data
end)

function OpenMarketMenu()
    local elements = {
        {label = 'Kunst kaufen', value = 'buy'},
        {label = 'Kunst verkaufen', value = 'sell'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'art_market_main_menu', {
        title = 'Kunsthandel',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
        if data.current.value == 'buy' then
            OpenBuyMenu()
        elseif data.current.value == 'sell' then
            -- First, trigger the server event to get the player's artworks
            -- The event handler 'art_trade:setPlayerArtworks' will open the menu
            ShowNotification('Lade deine Kunstwerke...')
            TriggerServerEvent('art_trade:getPlayerArtworks')
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenBuyMenu()
    local elements = {}

    if #artworks == 0 then
        table.insert(elements, { label = 'Keine Kunstwerke verfügbar.', value = 'back' })
    else
        for _, artwork in ipairs(artworks) do
            table.insert(elements, {
                label = artwork.label .. ' - $' .. artwork.price,
                value = artwork.id
            })
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'art_market_buy_menu', {
        title = 'Kunst kaufen',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
        if data.current.value ~= 'back' then
            TriggerServerEvent('art_trade:tradeArt', 'buy', data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Renamed to avoid confusion, this is the real menu opening
function OpenSellMenuInternal()
    local elements = {}

    if #playerArtworks == 0 then
        table.insert(elements, { label = 'Du besitzt keine Kunstwerke.', value = 'back' })
    else
        for _, artwork in ipairs(playerArtworks) do
            table.insert(elements, {
                label = artwork.label .. ' - $' .. math.floor(artwork.price * 0.5) .. ' (Verkaufspreis)',
                value = artwork.player_artwork_id -- This is the ID from the player_artworks table
            })
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'art_market_sell_menu', {
        title = 'Eigene Kunstwerke verkaufen',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
        if data.current.value ~= 'back' then
            -- The second argument is now the player_artwork_id, not the artwork_id
            TriggerServerEvent('art_trade:tradeArt', 'sell', data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end)
end
