ESX.RegisterServerCallback('graffiti:buySprayCan', function(source, cb, color)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.SprayCanPrice

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem("spraycan_" .. color, 1)
        cb(true)
    else
        cb(false)
    end
end)
