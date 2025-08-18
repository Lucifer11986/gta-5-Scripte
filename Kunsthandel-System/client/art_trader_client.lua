RegisterNetEvent('art_trade:openMarket')
AddEventHandler('art_trade:openMarket', function(artworks, playerArtworks)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openMarket',
        artworks = artworks,
        playerArtworks = playerArtworks
    })
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('art_trade:tradeArt', 'buy', data.artworkId)
    cb('ok')
end)

RegisterNUICallback('sell', function(data, cb)
    TriggerServerEvent('art_trade:tradeArt', 'sell', data.artworkId)
    cb('ok')
end)