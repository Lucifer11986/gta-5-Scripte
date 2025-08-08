Config = Config or {}
ESX = exports['es_extended']:getSharedObject()

-- Callback für Spieler, um Bonität und Kreditstatus zu überprüfen
ESX.RegisterServerCallback("boni_pruefung:getPlayerCreditInfo", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(nil)
        return
    end

    local identifier = xPlayer.identifier
    local query = "SELECT id, amount, interest, due_date, status FROM player_loans WHERE identifier = ? AND status = 'pending'"

    exports.oxmysql:execute(query, { identifier }, function(result)
        cb(result and #result > 0 and result or nil)
    end)
end)

-- Spieler-Befehl: Bonitätsprüfung
RegisterCommand("checkcredit", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    exports.oxmysql:execute('SELECT credit_score, outstanding_loans, missed_payments FROM users WHERE identifier = ?', { identifier }, function(result)
        if not result[1] then
            TriggerClientEvent("ShowTemporaryMessage", source, "Keine Bonitätsdaten gefunden.", 5000)
            return
        end

        local creditScore = tonumber(result[1].credit_score) or 0
        local outstandingLoans = tonumber(result[1].outstanding_loans) or 0
        local missedPayments = tonumber(result[1].missed_payments) or 0

        TriggerClientEvent("ShowTemporaryMessage", source, ("Deine Bonität: %d\nOffene Kredite: $%d\nVerpasste Zahlungen: %d"):format(
            creditScore, outstandingLoans, missedPayments
        ), 10000)
    end)
end, true, false)

-- Banker-Befehl: Bonitätsprüfung eines Spielers
RegisterCommand("checkcreditplayer", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getJob().name ~= Config.BankerJob then
        TriggerClientEvent("ShowTemporaryMessage", source, "Du bist kein Banker und hast keinen Zugriff.", 5000)
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent("ShowTemporaryMessage", source, "Nutzung: /checkcreditplayer [PlayerID]", 5000)
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent("ShowTemporaryMessage", source, "Spieler nicht gefunden.", 5000)
        return
    end

    local targetIdentifier = targetPlayer.identifier
    exports.oxmysql:execute('SELECT credit_score, outstanding_loans, missed_payments FROM users WHERE identifier = ?', { targetIdentifier }, function(result)
        if not result[1] then
            TriggerClientEvent("ShowTemporaryMessage", source, "Keine Bonitätsdaten für den Spieler gefunden.", 5000)
            return
        end

        local creditScore = tonumber(result[1].credit_score) or 0
        local outstandingLoans = tonumber(result[1].outstanding_loans) or 0
        local missedPayments = tonumber(result[1].missed_payments) or 0

        TriggerClientEvent("ShowTemporaryMessage", source, ("Spieler ID: %d\nBonität: %d\nOffene Kredite: $%d\nVerpasste Zahlungen: %d"):format(
            targetId, creditScore, outstandingLoans, missedPayments
        ), 10000)
    end)
end, true, false)

-- Kreditrückzahlung
RegisterCommand("payloan", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local payment = tonumber(args[1])
    if not payment or payment <= 0 then
        TriggerClientEvent("ShowTemporaryMessage", source, "Nutzung: /payloan [Betrag]", 5000)
        return
    end

    local identifier = xPlayer.identifier
    exports.oxmysql:execute('SELECT outstanding_loans FROM users WHERE identifier = ?', { identifier }, function(loanResult)
        local loan = loanResult[1] and loanResult[1].outstanding_loans or 0
        if loan <= 0 then
            TriggerClientEvent("ShowTemporaryMessage", source, "Du hast keine ausstehenden Kredite.", 5000)
            return
        end

        if xPlayer.getAccount('bank').money < payment then
            TriggerClientEvent("ShowTemporaryMessage", source, "Nicht genug Geld auf der Bank.", 5000)
            return
        end

        xPlayer.removeAccountMoney('bank', payment)
        local remainingLoan = math.max(0, loan - payment)

        exports.oxmysql:execute('UPDATE users SET outstanding_loans = ? WHERE identifier = ?', { remainingLoan, identifier })
        TriggerClientEvent("ShowTemporaryMessage", source, "Du hast $" .. payment .. " auf deinen Kredit zurückgezahlt. Verbleibender Kredit: $" .. remainingLoan, 5000)
    end)
end, true, false)

-- Kreditvergabe
RegisterCommand("givecredit", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getJob().name ~= Config.BankerJob then
        TriggerClientEvent("ShowTemporaryMessage", source, "Du bist kein Banker.", 5000)
        return
    end

    local targetId = tonumber(args[1])
    local creditAmount = tonumber(args[2])
    if not targetId or not creditAmount then
        TriggerClientEvent("ShowTemporaryMessage", source, "Nutzung: /givecredit [PlayerID] [Betrag]", 5000)
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        TriggerClientEvent("ShowTemporaryMessage", source, "Spieler nicht gefunden.", 5000)
        return
    end

    local targetIdentifier = targetPlayer.identifier
    exports.oxmysql:execute('INSERT INTO player_loans (identifier, amount, status) VALUES (?, ?, "pending")', 
    { targetIdentifier, creditAmount })

    targetPlayer.addAccountMoney('bank', creditAmount)
    TriggerClientEvent("ShowTemporaryMessage", source, "Kredit von $" .. creditAmount .. " vergeben.", 5000)
    TriggerClientEvent("ShowTemporaryMessage", targetId, "Du hast einen Kredit von $" .. creditAmount .. " erhalten.", 5000)
end, true, false)
