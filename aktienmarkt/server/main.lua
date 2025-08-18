ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Helper function to refresh a player's portfolio
local function refreshPlayerPortfolio(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    MySQL.Async.fetchAll('SELECT s.label, ps.stock_name, ps.amount, s.price FROM player_stocks ps JOIN stocks s ON ps.stock_name = s.name WHERE ps.identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        TriggerClientEvent('aktienmarkt:updateMyStocks', source, result)
    end)
end

-- Get all stocks of a certain category
RegisterNetEvent('aktienmarkt:getStocks')
AddEventHandler('aktienmarkt:getStocks', function(category)
    local _source = source
    MySQL.Async.fetchAll('SELECT * FROM stocks WHERE category = @category ORDER BY label ASC', {
        ['@category'] = category
    }, function(result)
        TriggerClientEvent('aktienmarkt:updateStocks', _source, result)
    end)
end)

-- Get the stocks owned by the player
RegisterNetEvent('aktienmarkt:getMyStocks')
AddEventHandler('aktienmarkt:getMyStocks', function()
    refreshPlayerPortfolio(source)
end)

-- Buy a stock
RegisterNetEvent('aktienmarkt:buyStock')
AddEventHandler('aktienmarkt:buyStock', function(stockName, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    amount = tonumber(amount)

    if not xPlayer or not stockName or not amount or amount <= 0 then return end

    MySQL.Async.fetch('SELECT price FROM stocks WHERE name = @name', {['@name'] = stockName}, function(stock)
        if not stock then
            TriggerClientEvent('esx:showNotification', _source, "~r~Diese Aktie existiert nicht.")
            return
        end

        local totalPrice = stock.price * amount
        if xPlayer.getMoney() >= totalPrice then
            xPlayer.removeMoney(totalPrice)

            MySQL.Async.execute(
                'INSERT INTO player_stocks (identifier, stock_name, amount) VALUES (@identifier, @stock_name, @amount) ON DUPLICATE KEY UPDATE amount = amount + @amount',
                {
                    ['@identifier'] = xPlayer.identifier,
                    ['@stock_name'] = stockName,
                    ['@amount'] = amount
                },
                function(rowsChanged)
                    TriggerClientEvent('esx:showNotification', _source, `~g~Du hast ${amount}x ${stockName} für $${totalPrice} gekauft.`)
                    refreshPlayerPortfolio(_source)
                end
            )
        else
            TriggerClientEvent('esx:showNotification', _source, "~r~Du hast nicht genug Geld.")
        end
    end)
end)

-- Sell a stock
RegisterNetEvent('aktienmarkt:sellStock')
AddEventHandler('aktienmarkt:sellStock', function(stockName, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    amount = tonumber(amount)

    if not xPlayer or not stockName or not amount or amount <= 0 then return end

    MySQL.Async.fetch('SELECT amount FROM player_stocks WHERE identifier = @identifier AND stock_name = @stock_name', {
        ['@identifier'] = xPlayer.identifier,
        ['@stock_name'] = stockName
    }, function(playerStock)
        if not playerStock or playerStock.amount < amount then
            TriggerClientEvent('esx:showNotification', _source, "~r~Du besitzt nicht genügend Aktien davon.")
            return
        end

        MySQL.Async.fetch('SELECT price FROM stocks WHERE name = @name', {['@name'] = stockName}, function(stock)
            if not stock then return end -- Should not happen if they own it, but as a safeguard

            local totalPrice = stock.price * amount
            xPlayer.addMoney(totalPrice)

            local newAmount = playerStock.amount - amount
            local sql = ''
            if newAmount > 0 then
                sql = 'UPDATE player_stocks SET amount = @new_amount WHERE identifier = @identifier AND stock_name = @stock_name'
            else
                sql = 'DELETE FROM player_stocks WHERE identifier = @identifier AND stock_name = @stock_name'
            end

            MySQL.Async.execute(sql, {
                ['@new_amount'] = newAmount,
                ['@identifier'] = xPlayer.identifier,
                ['@stock_name'] = stockName
            }, function(rowsChanged)
                TriggerClientEvent('esx:showNotification', _source, `~g~Du hast ${amount}x ${stockName} für $${totalPrice} verkauft.`)
                refreshPlayerPortfolio(_source)
            end)
        end)
    end)
end)

-- Dynamic Price Change Thread
Citizen.CreateThread(function()
    if not config.DynamicPrices.enabled then return end

    while true do
        -- Wait for the configured interval
        Citizen.Wait(config.DynamicPrices.changeIntervalMinutes * 60 * 1000)

        MySQL.Async.fetchAll('SELECT * FROM stocks', {}, function(stocks)
            if not stocks then return end

            local queries = {}
            for i=1, #stocks do
                local stock = stocks[i]
                local price = stock.price
                local changePercent = (math.random() * 2 - 1) * config.DynamicPrices.maxChangePercent / 100
                local newPrice = math.floor(price * (1 + changePercent))

                -- Prevent prices from going to 0 or below
                if newPrice <= 0 then
                    newPrice = 1
                end

                table.insert(queries, {
                    query = "UPDATE stocks SET price = @price WHERE name = @name",
                    parameters = {
                        ['@price'] = newPrice,
                        ['@name'] = stock.name
                    }
                })
            end

            if #queries > 0 then
                MySQL.Async.transaction(queries, function(success)
                    if success then
                        print("Stock prices updated successfully.")
                        if config.DynamicPrices.broadcastUpdate then
                            TriggerClientEvent('esx:showNotification', -1, "Die Aktienkurse wurden soeben aktualisiert!")
                        end
                        -- We don't need to broadcast the new prices here,
                        -- as the client will fetch the new prices when they open the UI or filter categories.
                        -- A more advanced implementation could broadcast the changes to open UIs.
                    else
                        print("Failed to update stock prices.")
                    end
                end)
            end
        end)
    end
end)
