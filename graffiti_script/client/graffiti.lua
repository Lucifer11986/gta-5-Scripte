local selectedColor = "red"
local selectedMotiv = "Motiv 1"

RegisterCommand("selectColor", function(_, args)
    selectedColor = args[1] or "red"
    TriggerEvent("esx:showNotification", "Farbe gewählt: " .. Config.Colors[selectedColor])
end)

RegisterCommand("selectMotiv", function(_, args)
    selectedMotiv = args[1] or "Motiv 1"
    TriggerEvent("esx:showNotification", "Motiv gewählt: " .. selectedMotiv)
end)

RegisterCommand("spray", function()
    local xPlayer = ESX.GetPlayerData()

    if xPlayer.getInventoryItem('spraycan').count > 0 then
        TriggerEvent("graffiti:startSpray")
    else
        TriggerEvent("esx:showNotification", "Keine Spraydose im Inventar!")
    end
end)

RegisterNetEvent("graffiti:startSpray")
AddEventHandler("graffiti:startSpray", function()
    TriggerEvent("graffiti:sprayWithColorAndMotiv")
end)

RegisterNetEvent("graffiti:sprayWithColorAndMotiv")
AddEventHandler("graffiti:sprayWithColorAndMotiv", function()
    print("Sprühfarbe: " .. Config.Colors[selectedColor] .. ", Motiv: " .. selectedMotiv)
end)
