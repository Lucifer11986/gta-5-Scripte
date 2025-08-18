local colors = {
    'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink', 'black', 'white', 'grey',
    'brown', 'cyan', 'magenta', 'turquoise', 'lime', 'gold', 'silver', 'chrome', 'holographic', 'fire'
}

for _, color in ipairs(colors) do
    local itemName = 'spraycan_' .. color
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(itemName, 1)
        TriggerClientEvent('graffiti:useSpray', source, color)
    end)
end
