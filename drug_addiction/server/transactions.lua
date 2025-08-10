local ESX, ESY, QBCore

-- Dynamisches Erkennen des Frameworks
CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('esy') == 'started' then
        ESY = exports['esy']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end)

-- Funktion zum Abrufen eines Spielers
local function getPlayer(source)
    if ESX then return ESX.GetPlayerFromId(source) end
    if ESY then return ESY.GetPlayerFromId(source) end
    if QBCore then return QBCore.Functions.GetPlayer(source) end
    return nil
end

-- Funktion zum Aktualisieren des Suchtlevels
local function setAddictionLevel(identifier, level)
    MySQL.Async.execute('UPDATE drug_addiction SET addiction_level = ? WHERE identifier = ?', { level, identifier })
end

RegisterNetEvent('drug_addiction:setLevel', function(level)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    setAddictionLevel(player.identifier, level)
    TriggerClientEvent('drug_addiction:updateLevel', src, level)
end)

-- Entzugserscheinungen prüfen
RegisterNetEvent('drug_system:checkWithdrawal', function()
    local src = source
    local player = getPlayer(src)
    if not player then return end

    MySQL.query('SELECT addiction_level FROM drug_addiction WHERE identifier = ?', { player.identifier }, function(result)
        if result[1] and result[1].addiction_level >= 0.5 then
            TriggerClientEvent('drug_system:startWithdrawal', src)
        end
    end)
end)

-- Therapie starten
RegisterNetEvent('drug_addiction:startRehab', function(targetId)
    local src = source
    local medic = getPlayer(src)
    local patient = getPlayer(targetId)

    if not medic or not patient then return end
    if medic.job.name ~= "ambulance" then
        TriggerClientEvent('esx:showNotification', src, 'Nur Medics können eine Therapie durchführen!')
        return
    end

    local item = medic.getInventoryItem(Config.RehabItem)
    if item.count < 1 then
        TriggerClientEvent('esx:showNotification', src, 'Du benötigst das Medikament "' .. Config.RehabItem .. '"!')
        return
    end

    local cost = Config.RehabCost
    if patient.getAccount('bank').money < cost then
        TriggerClientEvent('esx:showNotification', src, 'Der Patient hat nicht genug Geld für die Therapie!')
        return
    end

    medic.removeInventoryItem(Config.RehabItem, 1)
    patient.removeAccountMoney('bank', cost)

    TriggerClientEvent('drug_system:beginRehab', targetId)
    setAddictionLevel(patient.identifier, 0)
    TriggerClientEvent('drug_addiction:updateLevel', targetId, 0)
    TriggerClientEvent('esx:showNotification', src, 'Du hast die Therapie erfolgreich durchgeführt!')
    TriggerClientEvent('esx:showNotification', targetId, 'Ein Medic hat deine Therapie gestartet.')
end)