local useOxMySQL = GetResourceState('oxmysql') == 'started' -- Automatische Erkennung

local function executeQuery(query, params, callback)
    if useOxMySQL then
        MySQL.query(query, params, function(result)
            if callback then callback(result) end
        end)
    else
        MySQL.Async.fetchAll(query, params, function(result)
            if callback then callback(result) end
        end)
    end
end

-- 📌 Datenbank-Tabelle erstellen, falls sie nicht existiert
executeQuery([[
    CREATE TABLE IF NOT EXISTS player_addiction (
        identifier VARCHAR(50) PRIMARY KEY,
        addiction_level INT DEFAULT 0
    )
]])

-- 📌 Suchtlevel eines Spielers abrufen
function getAddictionLevel(identifier, callback)
    executeQuery("SELECT addiction_level FROM player_addiction WHERE identifier = ?", {identifier}, function(result)
        if result[1] then
            callback(result[1].addiction_level)
        else
            callback(0)
        end
    end)
end

-- 📌 Suchtlevel aktualisieren
function setAddictionLevel(identifier, level)
    executeQuery("INSERT INTO player_addiction (identifier, addiction_level) VALUES (?, ?) ON DUPLICATE KEY UPDATE addiction_level = ?", 
    {identifier, level, level})
end
