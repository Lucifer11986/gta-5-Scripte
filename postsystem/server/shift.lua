ESX = exports["es_extended"]:getSharedObject()

local playersOnShift = {}

-- Schicht starten
RegisterNetEvent('postsystem:startPostmanShift')
AddEventHandler('postsystem:startPostmanShift', function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Speichere den alten Job
    playersOnShift[player.identifier] = {
        job = player.job.name,
        grade = player.job.grade
    }

    -- Setze den Postboten-Job
    player.setJob(Config.PostmanJob.JobName, 0)
    TriggerClientEvent('postsystem:setUniform', src, 'postman')
    TriggerClientEvent('esx:showNotification', src, 'Du hast deine Schicht als Postbote begonnen.')
end)

-- Schicht beenden
RegisterNetEvent('postsystem:endPostmanShift')
AddEventHandler('postsystem:endPostmanShift', function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    local oldJobData = playersOnShift[player.identifier]
    local oldJob = oldJobData and oldJobData.job or Config.DefaultJob.JobName
    local oldGrade = oldJobData and oldJobData.grade or Config.DefaultJob.Grade

    player.setJob(oldJob, oldGrade)
    playersOnShift[player.identifier] = nil

    TriggerClientEvent('postsystem:restoreClothing', src)
    TriggerClientEvent('esx:showNotification', src, 'Du hast deine Schicht beendet.')
end)

-- Sicherstellen, dass Spieler bei Verbindungsabbruch aus der Schicht entfernt werden
AddEventHandler('esx:playerDropped', function(playerId, reason)
    local player = ESX.GetPlayerFromId(playerId)
    if player and playersOnShift[player.identifier] then
        playersOnShift[player.identifier] = nil
    end
end)
