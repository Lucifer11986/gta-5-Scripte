local artworks = {}

RegisterNetEvent('art_trade:setArtworks')
AddEventHandler('art_trade:setArtworks', function(result)
    artworks = result
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
        if data.current.value == 'buy' then
            OpenBuyMenu()
        elseif data.current.value == 'sell' then
            OpenSellMenu()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenBuyMenu()
    local elements = {}

    for _, artwork in ipairs(artworks) do
        table.insert(elements, {
            label = artwork.label .. ' - $' .. artwork.price,
            value = artwork.id
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'art_market_buy_menu', {
        title = 'Kunst kaufen',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('art_trade:tradeArt', 'buy', data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

function OpenSellMenu()
    local elements = {}

    for _, artwork in ipairs(artworks) do
        table.insert(elements, {
            label = artwork.label .. ' - $' .. math.floor(artwork.price * 0.5) .. ' (Verkaufspreis)',
            value = artwork.id
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'art_market_sell_menu', {
        title = 'Kunst verkaufen',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('art_trade:tradeArt', 'sell', data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end