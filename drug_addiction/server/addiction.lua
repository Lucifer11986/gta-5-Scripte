ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('drug_system:updateAddiction')
AddEventHandler('drug_system:updateAddiction', function(level)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        MySQL.update('UPDATE users SET addiction = ? WHERE identifier = ?', {level, xPlayer.identifier})
    end
end)

RegisterServerEvent('drug_system:reduceAddiction')
AddEventHandler('drug_system:reduceAddiction', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        MySQL.single('SELECT addiction FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
            if result and result.addiction then
                local newLevel = math.max(0, result.addiction - 5)
                MySQL.update('UPDATE users SET addiction = ? WHERE identifier = ?', {newLevel, xPlayer.identifier})
                TriggerClientEvent('esx:showNotification', src, 'Deine Abhängigkeit sinkt langsam.')
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000) -- Alle 10 Minuten
        for _, playerId in ipairs(GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(tonumber(playerId))
            if xPlayer then
                MySQL.single('SELECT addiction FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
                    if result and result.addiction then
                        local newLevel = math.max(0, result.addiction - 5)
                        MySQL.update('UPDATE users SET addiction = ? WHERE identifier = ?', {newLevel, xPlayer.identifier})
                        TriggerClientEvent('esx:showNotification', playerId, 'Deine Abhängigkeit sinkt langsam.')
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent('drug_system:applyNewDrugEffects')
AddEventHandler('drug_system:applyNewDrugEffects', function(drug)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    if drug == "ecstasy" then
        TriggerClientEvent('esx:showNotification', src, 'Du fühlst dich euphorisch!')
    elseif drug == "heroin" then
        MySQL.update('UPDATE users SET addiction = addiction + 10 WHERE identifier = ?', {xPlayer.identifier})
        TriggerClientEvent('esx:showNotification', src, 'Dein Schmerz lässt nach, aber du fühlst dich abhängig...')
    elseif drug == "mushrooms" then
        TriggerClientEvent('drug_system:triggerHallucinations', src)
        TriggerClientEvent('esx:showNotification', src, 'Die Welt sieht... anders aus!')
    end
end)
