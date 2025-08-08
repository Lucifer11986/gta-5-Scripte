ESX = exports.es_extended:getSharedObject()

-- WORKAROUND for un-editable config.lua
-- These values are hardcoded because config.lua could not be modified.
Config.BankerJob = "banker"
Config.PremiumRoles = { ["vip"] = 10, ["elite"] = 20 }


-- Helper function for notifications
local function notify(source, message)
    TriggerClientEvent("boni_pruefung:showNotification", source, message)
end

-- Callback to get player's active loans for the UI
ESX.RegisterServerCallback("boni_pruefung:getOutstandingLoans", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    local query = "SELECT id, amount, remaining_balance, interest_rate, due_date FROM loan_transactions WHERE identifier = ? AND status = 'laufend'"
    exports.oxmysql:single(query, { xPlayer.identifier }, function(result)
        cb(result)
    end)
end)


-- Command for a player to check their own credit
RegisterCommand("checkcredit", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    exports.oxmysql:single('SELECT credit_score, outstanding_loans, missed_payments FROM users WHERE identifier = ?', { identifier }, function(result)
        if not result then
            notify(source, "Keine Bonitätsdaten gefunden.")
            return
        end

        notify(source, string.format("Deine Bonität: %d | Offene Kredite: $%d | Verpasste Zahlungen: %d",
            result.credit_score, result.outstanding_loans, result.missed_payments))
    end)
end, false) -- false = available to all players

-- Command for a banker to check another player's credit
RegisterCommand("checkcreditplayer", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.getJob().name ~= Config.BankerJob then
        notify(source, "Du bist kein Banker.")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        notify(source, "Nutzung: /checkcreditplayer [PlayerID]")
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        notify(source, "Spieler nicht gefunden.")
        return
    end

    local targetIdentifier = targetPlayer.identifier
    exports.oxmysql:single('SELECT credit_score, outstanding_loans, missed_payments FROM users WHERE identifier = ?', { targetIdentifier }, function(result)
        if not result then
            notify(source, "Keine Bonitätsdaten für diesen Spieler gefunden.")
            return
        end

        notify(source, string.format("Spieler ID %d: Bonität: %d | Offene Kredite: $%d | Verpasste Zahlungen: %d",
            targetId, result.credit_score, result.outstanding_loans, result.missed_payments))
    end)
end, false) -- job check is enough

-- Command for a banker to give a loan to a player
RegisterCommand("givecredit", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.getJob().name ~= Config.BankerJob then
        notify(source, "Du bist kein Banker.")
        return
    end

    local targetId = tonumber(args[1])
    local creditAmount = tonumber(args[2])

    if not targetId or not creditAmount or creditAmount <= 0 then
        notify(source, "Nutzung: /givecredit [PlayerID] [Betrag]")
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        notify(source, "Spieler nicht gefunden.")
        return
    end

    -- For simplicity, using a fixed interest rate. This could be dynamic based on Config.InterestRates
    local interestRate = 5.0 -- 5%
    local totalRepayment = math.floor(creditAmount * (1 + (interestRate / 100)))
    local dueDate = os.date("%Y-%m-%d", os.time() + (Config.RepaymentInterval * 60 * 30)) -- Due in 30 intervals

    local loanDetails = {
        identifier = targetPlayer.identifier,
        amount = creditAmount,
        interest_rate = interestRate,
        total_repayment = totalRepayment,
        remaining_balance = totalRepayment,
        due_date = dueDate,
        status = 'laufend'
    }

    exports.oxmysql:insert('INSERT INTO loan_transactions SET ?', { loanDetails }, function(insertId)
        if insertId then
            -- Now update the user's total outstanding loans
            exports.oxmysql:execute('UPDATE users SET outstanding_loans = outstanding_loans + ? WHERE identifier = ?', { totalRepayment, targetPlayer.identifier })
            targetPlayer.addAccountMoney('bank', creditAmount)
            notify(source, string.format("Kredit von $%d an Spieler %d vergeben.", creditAmount, targetId))
            notify(targetId, string.format("Du hast einen Kredit von $%d erhalten. Gesamtrückzahlung: $%d.", creditAmount, totalRepayment))
        else
            notify(source, "Fehler bei der Kreditvergabe.")
        end
    end)
end, false)

-- Function to handle loan repayment logic
local function handleLoanRepayment(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local payment = tonumber(amount)
    if not payment or payment <= 0 then
        notify(source, "Ungültiger Betrag.")
        return
    end

    if xPlayer.getAccount('bank').money < payment then
        notify(source, "Du hast nicht genug Geld auf der Bank.")
        return
    end

    -- This is a simplified logic. A real system would need to handle multiple loans.
    -- For now, we just reduce the total outstanding loan amount.
    exports.oxmysql:single('SELECT outstanding_loans FROM users WHERE identifier = ?', { xPlayer.identifier }, function(user)
        if not user or user.outstanding_loans <= 0 then
            notify(source, "Du hast keine ausstehenden Kredite.")
            return
        end

        local actualPayment = math.min(payment, user.outstanding_loans)
        xPlayer.removeAccountMoney('bank', actualPayment)

        exports.oxmysql:execute('UPDATE users SET outstanding_loans = outstanding_loans - ? WHERE identifier = ?', { actualPayment, xPlayer.identifier })
        -- Also update the loan_transactions table. This part is complex if there are multiple loans.
        -- We'll just mark the oldest loan as paid if the total is covered. This is a simplification.
        exports.oxmysql:execute('UPDATE loan_transactions SET remaining_balance = remaining_balance - ? WHERE identifier = ? AND status = "laufend" ORDER BY due_date ASC LIMIT 1', { actualPayment, xPlayer.identifier })

        notify(source, string.format("Du hast $%d deines Kredits zurückgezahlt.", actualPayment))

        -- Check if loan is fully paid
        exports.oxmysql:single('SELECT SUM(remaining_balance) as total_remaining FROM loan_transactions WHERE identifier = ? AND status = "laufend"', {xPlayer.identifier}, function(remaining)
            if remaining and remaining.total_remaining <= 0 then
                exports.oxmysql:execute('UPDATE loan_transactions SET status = "bezahlt" WHERE identifier = ? AND remaining_balance <= 0', {xPlayer.identifier})
                notify(source, "Herzlichen Glückwunsch! Du hast alle Kredite abbezahlt.")
            end
        end)
    end)
end

-- Command for a player to repay a loan
RegisterCommand("payloan", function(source, args, rawCommand)
    handleLoanRepayment(source, args[1])
end, false)

-- Net event for the NUI to call for loan repayment
RegisterNetEvent('boni_pruefung:payLoan')
AddEventHandler('boni_pruefung:payLoan', function(amount)
    local source = source
    handleLoanRepayment(source, amount)
end)

-- The old getPlayerCreditInfo seems unused by the client, so I'm removing it to avoid confusion.
-- If it's needed, it should be updated to use the correct table and provide useful info.
-- ESX.RegisterServerCallback("boni_pruefung:getPlayerCreditInfo", ...)
