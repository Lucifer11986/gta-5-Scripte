ESX = exports["es_extended"]:getSharedObject()

-- Graffitis aus der Datenbank laden, wenn der Server startet
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    MySQL.Async.fetchAll("SELECT * FROM graffiti", {}, function(result)
        for _, graffiti in ipairs(result) do
            TriggerClientEvent('graffiti:loadGraffiti', -1, graffiti)
        end
    end)
end)

-- Graffiti in der Datenbank speichern
RegisterNetEvent('graffiti:saveGraffiti')
AddEventHandler('graffiti:saveGraffiti', function(x, y, z, heading, sprayColor, image)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        MySQL.Async.execute("INSERT INTO graffiti (x, y, z, heading, color, image) VALUES (@x, @y, @z, @heading, @color, @image)", {
            ["@x"] = x,
            ["@y"] = y,
            ["@z"] = z,
            ["@heading"] = heading,
            ["@color"] = sprayColor,
            ["@image"] = image
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('graffiti:loadGraffiti', -1, {x = x, y = y, z = z, heading = heading, color = sprayColor, image = image})
                TriggerClientEvent('esx:showNotification', src, "Graffiti erfolgreich gesprüht!")
            end
        end)
    end
end)

-- Graffiti aus der Datenbank entfernen (bei Reinigung)
RegisterNetEvent('graffiti:removeGraffiti')
AddEventHandler('graffiti:removeGraffiti', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        MySQL.Async.execute("DELETE FROM graffiti WHERE x = @x AND y = @y AND z = @z", {
            ["@x"] = coords.x,
            ["@y"] = coords.y,
            ["@z"] = coords.z
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('graffiti:deleteGraffiti', -1, coords)
                TriggerClientEvent('esx:showNotification', src, "Graffiti wurde entfernt!")
            end
        end)
    end
end)

RegisterNetEvent('graffiti:saveGraffiti')
AddEventHandler('graffiti:saveGraffiti', function(coords, image, color)
    exports.oxmysql:insert('INSERT INTO graffiti (x, y, z, image, color) VALUES (?, ?, ?, ?)',
    {coords.x, coords.y, coords.z, image, color}, function(id)
        TriggerClientEvent('graffiti:placeGraffiti', -1, coords, image, color)
    end)
end)
