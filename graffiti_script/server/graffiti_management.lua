ESX = exports["es_extended"]:getSharedObject()
local MySQL = exports.oxmysql
local LoadedGraffiti = {} -- Server-side cache for graffiti data

-- Helper function to get on-duty police players
function getPolicePlayers()
    local police = {}
    local players = ESX.GetPlayers()
    for i=1, #players do
        local xPlayer = ESX.GetPlayerFromId(players[i])
        if xPlayer.job.name == 'police' then
            table.insert(police, players[i])
        end
    end
    return police
end

-- Function to remove graffiti from the database and notify clients
function removeGraffiti(coords, source)
    MySQL:execute("DELETE FROM graffiti WHERE x = ? AND y = ? AND z = ?", {
        coords.x, coords.y, coords.z
    }, function(rowsChanged)
        if rowsChanged > 0 then
            for i = #LoadedGraffiti, 1, -1 do
                if LoadedGraffiti[i].x == coords.x and LoadedGraffiti[i].y == coords.y and LoadedGraffiti[i].z == coords.z then
                    table.remove(LoadedGraffiti, i)
                    break
                end
            end
            TriggerClientEvent('graffiti:deleteGraffiti', -1, coords)
            if source then
                TriggerClientEvent('esx:showNotification', source, "Graffiti wurde entfernt!")
            end
        end
    end)
end

-- Graffitis aus der Datenbank laden
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    MySQL:execute("SELECT *, UNIX_TIMESTAMP(created_at) as created_at_unix FROM graffiti", {}, function(result)
        LoadedGraffiti = result
        for _, graffiti in ipairs(LoadedGraffiti) do
            TriggerClientEvent('graffiti:loadGraffiti', -1, graffiti)
        end
        print(("^2[GraffitiScript] Loaded %d graffiti from the database."):format(#LoadedGraffiti))
    end)
end)

-- Graffiti in der Datenbank speichern
RegisterNetEvent('graffiti:saveGraffiti')
AddEventHandler('graffiti:saveGraffiti', function(newGraffitiCoords, heading, sprayColor, image, graffitiToOverwrite)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- If this is an overwrite, remove the old graffiti first
    if Config.EnableGraffitiWars and graffitiToOverwrite then
        removeGraffiti(graffitiToOverwrite, nil) -- No notification for the removal part of an overwrite
    else
        -- If not an overwrite, perform Anti-Spam Check
        local isTooClose = false
        for _, existingGraffiti in ipairs(LoadedGraffiti) do
            if #(newGraffitiCoords - vector3(existingGraffiti.x, existingGraffiti.y, existingGraffiti.z)) < Config.MinDistanceBetweenGraffiti then
                isTooClose = true
                break
            end
        end

        if isTooClose then
            return TriggerClientEvent('esx:showNotification', src, "Du kannst hier kein Graffiti sprühen, es ist zu nah an einem anderen.")
        end
    end

    MySQL:execute("INSERT INTO graffiti (x, y, z, heading, color, image) VALUES (?, ?, ?, ?, ?, ?)", {
        newGraffitiCoords.x, newGraffitiCoords.y, newGraffitiCoords.z, heading, sprayColor, image
    }, function(rowsChanged)
        if rowsChanged > 0 then
            local newGraffiti = {x = newGraffitiCoords.x, y = newGraffitiCoords.y, z = newGraffitiCoords.z, heading = heading, color = sprayColor, image = image, created_at_unix = os.time()}
            table.insert(LoadedGraffiti, newGraffiti)
            TriggerClientEvent('graffiti:loadGraffiti', -1, newGraffiti)
            TriggerClientEvent('esx:showNotification', src, "Graffiti erfolgreich gesprüht!")

            -- Police System Logic
            if Config.PoliceSystem.Enable then
                local police = getPolicePlayers()
                if #police >= Config.PoliceSystem.MinPoliceRequired then
                    if math.random() < Config.PoliceSystem.AlertChance then
                        for _, policeId in ipairs(police) do
                            TriggerClientEvent('graffiti:policeAlert', policeId, newGraffitiCoords)
                        end
                        print(("^2[GraffitiScript] Alerted %d police officers about a new graffiti."):format(#police))
                    end
                end
            end
        end
    end)
end)

-- Graffiti aus der Datenbank entfernen (bei manueller Reinigung)
RegisterNetEvent('graffiti:removeGraffiti')
AddEventHandler('graffiti:removeGraffiti', function(coords)
    removeGraffiti(coords, source)
end)

-- Thread for automatic graffiti cleanup
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000)
        if Config.GraffitiFadeTime and Config.GraffitiFadeTime > 0 then
            local now = os.time()
            local graffitiToRemove = {}
            for _, graffiti in ipairs(LoadedGraffiti) do
                if graffiti.created_at_unix and (now - graffiti.created_at_unix > Config.GraffitiFadeTime) then
                    table.insert(graffitiToRemove, graffiti)
                end
            end
            if #graffitiToRemove > 0 then
                print(("^2[GraffitiScript] Removing %d expired graffiti."):format(#graffitiToRemove))
                for _, graffiti in ipairs(graffitiToRemove) do
                    removeGraffiti(vector3(graffiti.x, graffiti.y, graffiti.z), nil)
                end
            end
        end
    end
end)