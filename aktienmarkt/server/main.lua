-- server/main.lua

-- Beispiel für den Server: SQL-Abfragen, Spielerdaten-Verarbeitung etc.
local oxmysql = exports['oxmysql']

-- Event für das Laden der Aktien
RegisterNetEvent('aktienmarkt:loadStocks')
AddEventHandler('aktienmarkt:loadStocks', function(category)
    local _source = source

    oxmysql.fetchAll('SELECT * FROM stock_market WHERE category = @category', {
        ['@category'] = category
    }, function(stocks)
        TriggerClientEvent('aktienmarkt:receiveStocks', _source, stocks)
    end)
end)

-- Event für Kauf/Verkauf von Aktien
RegisterNetEvent('aktienmarkt:transaction')
AddEventHandler('aktienmarkt:transaction', function(type, stockName)
    local xPlayer = ESX.GetPlayerFromId(source)

    oxmysql.fetchAll('SELECT * FROM stock_market WHERE name = @name', {
        ['@name'] = stockName
    }, function(stock)
        if stock and stock[1] then
            local stockPrice = stock[1].price

            if type == "buy" then
                if xPlayer.getMoney() >= stockPrice then
                    xPlayer.removeMoney(stockPrice)
                    TriggerClientEvent('esx:showNotification', source, "Du hast " .. stockName .. " für $" .. stockPrice .. " gekauft.")
                else
                    TriggerClientEvent('esx:showNotification', source, "Du hast nicht genug Geld, um " .. stockName .. " zu kaufen.")
                end
            elseif type == "sell" then
                if true then -- Inventar-Check hier hinzufügen
                    xPlayer.addMoney(stockPrice)
                    TriggerClientEvent('esx:showNotification', source, "Du hast " .. stockName .. " für $" .. stockPrice .. " verkauft.")
                else
                    TriggerClientEvent('esx:showNotification', source, "Du besitzt keine " .. stockName .. " zum Verkauf.")
                end
            end
        end
    end)
end)
