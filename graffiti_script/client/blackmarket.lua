ESX = exports["es_extended"]:getSharedObject()

local blackMarketOpen = false

-- Black Market Menü öffnen
RegisterNetEvent('graffiti:openBlackMarket')
AddEventHandler('graffiti:openBlackMarket', function()
    if blackMarketOpen then return end
    blackMarketOpen = true

    local elements = {
        {label = "Chrom Spraydose - $500", value = "chrom"},
        {label = "Holographic Spraydose - $600", value = "holo"},
        {label = "Feuer Spraydose - $700", value = "fire"},
        {label = "UV-Spray - $750", value = "uv"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'blackmarket_menu', {
        title    = "Black Market",
        align    = "top-left",
        elements = elements
    }, function(data, menu)
        local item = data.current.value
        TriggerServerEvent('graffiti:buyBlackMarketItem', item)
        menu.close()
        blackMarketOpen = false
    end, function(data, menu)
        menu.close()
        blackMarketOpen = false
    end)
end)

-- Keybinding für Black Market (Ändere 'F7' nach Wunsch)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 168) then -- F7
            TriggerEvent('graffiti:openBlackMarket')
        end
    end
end)
