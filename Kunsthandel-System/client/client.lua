local Config = {
    MarketCoords = vector3(250.0, -1050.0, 29.0)
}

local playerCoords = nil

CreateThread(function()
    while true do
        playerCoords = GetEntityCoords(PlayerPedId())
        Wait(500)
    end
end)

RegisterNetEvent('art_trade:openMarket')
AddEventHandler('art_trade:openMarket', function()
    if #(playerCoords - Config.MarketCoords) < 5.0 then
        OpenMarketMenu()
    else
        ESX.ShowNotification('~r~Du bist zu weit entfernt vom Kunsthändler!')
    end
end)