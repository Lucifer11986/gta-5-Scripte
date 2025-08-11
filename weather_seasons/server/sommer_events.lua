local Framework = nil

Citizen.CreateThread(function()
    while Framework == nil do
        if GetResourceState('es_extended') == 'started' then
            Framework = exports['es_extended']:getSharedObject()
        elseif GetResourceState('qb-core') == 'started' then
            Framework = exports['qb-core']:GetCoreObject()
        elseif GetResourceState('esy') == 'started' then
            Framework = exports['esy']:getSharedObject()
        end
        Citizen.Wait(500)
    end
end)

-- Sommer-Belohnung
RegisterServerEvent("sommer:giveReward")
AddEventHandler("sommer:giveReward", function()
    local src = source
    local xPlayer = nil

    if Framework.GetPlayerFromId then
        xPlayer = Framework.GetPlayerFromId(src)
    elseif Framework.Functions and Framework.Functions.GetPlayer then
        xPlayer = Framework.Functions.GetPlayer(src)
    end

    if xPlayer then
        local moneyReward = math.random(50, 200) -- Zufällige Belohnung zwischen 50 und 200$
        if xPlayer.addAccountMoney then
            xPlayer.addAccountMoney("money", moneyReward)
        elseif xPlayer.Functions and xPlayer.Functions.AddMoney then
            xPlayer.Functions.AddMoney("cash", moneyReward, "sommer-event")
        end
        TriggerClientEvent('chat:addMessage', src, { args = { "[SOMMER]", "Du hast $" .. moneyReward .. " für deine Sommeraktivität erhalten!" } })
    end
end)

-- Wasser-Battle Schaden anwenden
RegisterServerEvent("sommer:applyWaterDamage")
AddEventHandler("sommer:applyWaterDamage", function(targetPed)
    local src = source
    local xPlayer = nil

    if Framework.GetPlayerFromId then
        xPlayer = Framework.GetPlayerFromId(src)
    elseif Framework.Functions and Framework.Functions.GetPlayer then
        xPlayer = Framework.Functions.GetPlayer(src)
    end

    if xPlayer then
        -- Schaden anwenden (hier einfaches Beispiel, du kannst auch andere Mechaniken hinzufügen)
        local damage = 10 -- Schaden durch Wasserpistole
        TriggerClientEvent('chat:addMessage', src, { args = { "[SOMMER]", "Du hast dem Zielspieler " .. damage .. " Schaden zugefügt!" } })
        -- Hier könnte man auch das Leben des Zielspielers verringern oder andere Effekte einbauen
    end
end)

-- Ernte-Wettbewerb Punktestand aktualisieren
RegisterServerEvent("sommer:updateHarvestScore")
AddEventHandler("sommer:updateHarvestScore", function(score)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    MySQL.query("SELECT * FROM sommer_rangliste WHERE player = ?", {identifier}, function(result)
        if result[1] then
            MySQL.update("UPDATE sommer_rangliste SET score = score + ? WHERE player = ?", {score, identifier})
        else
            MySQL.insert("INSERT INTO sommer_rangliste (player, score) VALUES (?, ?)", {identifier, score})
        end
    end)
end)

-- Sommer-Rangliste-Datenbank
MySQL.ready(function()
    MySQL.query("CREATE TABLE IF NOT EXISTS sommer_rangliste (id INT AUTO_INCREMENT PRIMARY KEY, player VARCHAR(255), score INT DEFAULT 0)")
end)

-- Sommer-Rangliste anzeigen
RegisterServerEvent("sommer:getLeaderboard")
AddEventHandler("sommer:getLeaderboard", function()
    local src = source
    MySQL.query("SELECT * FROM sommer_rangliste ORDER BY score DESC LIMIT 10", {}, function(result)
        local leaderboard = {}
        for _, entry in ipairs(result) do
            table.insert(leaderboard, entry)
        end
        TriggerClientEvent('sommer:showLeaderboard', src, leaderboard)
    end)
end)
