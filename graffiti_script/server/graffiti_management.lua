ESX = exports["es_extended"]:getSharedObject()
local MySQL = exports.oxmysql
local LoadedGraffiti = {} -- Server-side cache for graffiti locations

-- Graffitis aus der Datenbank laden, wenn der Server startet
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    MySQL:execute("SELECT * FROM graffiti", {}, function(result)
        LoadedGraffiti = result
        for _, graffiti in ipairs(LoadedGraffiti) do
            TriggerClientEvent('graffiti:loadGraffiti', -1, graffiti)
        end
        print(("^2[GraffitiScript] Loaded %d graffiti from the database."):format(#LoadedGraffiti))
    end)
end)

-- Graffiti in der Datenbank speichern
RegisterNetEvent('graffiti:saveGraffiti')
AddEventHandler('graffiti:saveGraffiti', function(x, y, z, heading, sprayColor, image)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local newGraffitiCoords = vector3(x, y, z)

    if not xPlayer then return end

    -- Anti-Spam Check
    local isTooClose = false
    for _, existingGraffiti in ipairs(LoadedGraffiti) do
        local existingCoords = vector3(existingGraffiti.x, existingGraffiti.y, existingGraffiti.z)
        if #(newGraffitiCoords - existingCoords) < Config.MinDistanceBetweenGraffiti then
            isTooClose = true
            break
        end
    end

    if isTooClose then
        TriggerClientEvent('esx:showNotification', src, "Du kannst hier kein Graffiti sprühen, es ist zu nah an einem anderen.")
        return
    end

    -- Save the new graffiti
    MySQL:execute("INSERT INTO graffiti (x, y, z, heading, color, image) VALUES (?, ?, ?, ?, ?, ?)", {
        x, y, z, heading, sprayColor, image
    }, function(rowsChanged)
        if rowsChanged > 0 then
            local newGraffiti = {x = x, y = y, z = z, heading = heading, color = sprayColor, image = image}
            table.insert(LoadedGraffiti, newGraffiti)
            TriggerClientEvent('graffiti:loadGraffiti', -1, newGraffiti)
            TriggerClientEvent('esx:showNotification', src, "Graffiti erfolgreich gesprüht!")
        end
    end)
end)

-- Graffiti aus der Datenbank entfernen (bei Reinigung)
RegisterNetEvent('graffiti:removeGraffiti')
AddEventHandler('graffiti:removeGraffiti', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    MySQL:execute("DELETE FROM graffiti WHERE x = ? AND y = ? AND z = ?", {
        coords.x, coords.y, coords.z
    }, function(rowsChanged)
        if rowsChanged > 0 then
            -- Remove from local cache
            for i = #LoadedGraffiti, 1, -1 do
                local g = LoadedGraffiti[i]
                if g.x == coords.x and g.y == coords.y and g.z == coords.z then
                    table.remove(LoadedGraffiti, i)
                    break
                end
            end
            TriggerClientEvent('graffiti:deleteGraffiti', -1, coords)
            TriggerClientEvent('esx:showNotification', src, "Graffiti wurde entfernt!")
        end
    end)
end)
