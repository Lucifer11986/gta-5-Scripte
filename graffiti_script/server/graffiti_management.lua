ESX = exports["es_extended"]:getSharedObject()
local MySQL = exports.oxmysql

-- Graffitis aus der Datenbank laden, wenn der Server startet
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    MySQL:execute("SELECT * FROM graffiti", {}, function(result)
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
        MySQL:execute("INSERT INTO graffiti (x, y, z, heading, color, image) VALUES (?, ?, ?, ?, ?, ?)", {
            x, y, z, heading, sprayColor, image
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
        MySQL:execute("DELETE FROM graffiti WHERE x = ? AND y = ? AND z = ?", {
            coords.x, coords.y, coords.z
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('graffiti:deleteGraffiti', -1, coords)
                TriggerClientEvent('esx:showNotification', src, "Graffiti wurde entfernt!")
            end
        end)
    end
end)
