-- Funktion zum Öffnen des Sommermarktes (Server-seitig)
RegisterServerEvent("start_summer_market")
AddEventHandler("start_summer_market", function()
    -- Öffnen des Marktes für alle Spieler
    TriggerClientEvent("OpenSummerMarket", -1)
end)

-- Funktion zum Schließen des Marktes (Server-seitig)
RegisterServerEvent("end_summer_market")
AddEventHandler("end_summer_market", function()
    -- Marktplatz schließen
    TriggerClientEvent("CloseSummerMarket", -1)
end)

-- Funktion zum Kauf von Items vom Sommermarkt
RegisterServerEvent("buy_from_summer_market")
AddEventHandler("buy_from_summer_market", function(itemName, itemPrice)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getMoney() >= itemPrice then
        xPlayer.removeMoney(itemPrice)  -- Geld abziehen
        xPlayer.addInventoryItem(itemName, 1)  -- Item zum Inventar hinzufügen
        TriggerClientEvent("notification", source, "Du hast " .. itemName .. " für " .. itemPrice .. "$ gekauft.")
    else
        TriggerClientEvent("notification", source, "Du hast nicht genug Geld für dieses Item.")
    end
end)
