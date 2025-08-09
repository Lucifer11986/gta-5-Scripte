ESX.RegisterServerCallback('graffiti:buyBlackMarketSpray', function(source, cb, color)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.BlackMarketPrices[color]

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem("spraycan_" .. color, 1)
        cb(true)
    else
        cb(false)
    end
end)
