local shopOpen = false

RegisterNetEvent('graffiti:openShop')
AddEventHandler('graffiti:openShop', function()
    if shopOpen then return end
    shopOpen = true

    local elements = {
        {label = "🔴 Rote Spraydose - 50$", value = "spray_can_red"},
        {label = "🔵 Blaue Spraydose - 50$", value = "spray_can_blue"},
        {label = "🟢 Grüne Spraydose - 50$", value = "spray_can_green"},
        {label = "⚫ Schwarze Spraydose - 50$", value = "spray_can_black"},
        {label = "⚪ Weiße Spraydose - 50$", value = "spray_can_white"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spray_shop', {
        title    = '🎨 Spraydosen Shop',
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('graffiti:buySpray', data.current.value)
    end, function(data, menu)
        menu.close()
        shopOpen = false
    end)
end)

RegisterCommand("sprayshop", function()
    TriggerEvent('graffiti:openShop')
end, false)
