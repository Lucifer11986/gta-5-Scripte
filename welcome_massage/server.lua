-- **🔗 MySQL-Abfragefunktion**
local function MySQLQuery(query, params, callback)
    if IsOxMySQLAvailable() then
        exports.oxmysql:query(query, params, callback)
    else
        print("❌ Kein MySQL-Framework gefunden!")
    end
end

-- **🛠 Überprüfen, ob oxmysql verfügbar ist**
function IsOxMySQLAvailable()
    local success, result = pcall(function()
        return exports.oxmysql
    end)
    return success and result ~= nil
end

-- **🚪 Event: Spieler verbindet sich**
AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local playerId = source
    local identifier = GetPlayerIdentifier(playerId)

    deferrals.defer()  -- ⏳ Verbindung wird überprüft

    -- 📋 Überprüfung auf Bannliste
    Citizen.Wait(500)
    MySQLQuery("SELECT banned FROM users WHERE identifier = @identifier", { ["@identifier"] = identifier }, function(result)
        if result[1] and result[1].banned then
            -- 🚫 Spieler ist gebannt
            deferrals.done("❌ Du bist auf diesem Server gebannt.")
        else
            -- 🔧 Server-Status abrufen
            local serverStatus = GetServerStatus()

            if serverStatus == "maintenance" then
                -- 🏗 Wartungsmodus
                deferrals.done("⚠️ Der Server befindet sich in Wartung.")
            else
                deferrals.done()  -- ✅ Spieler darf beitreten
            end
        end
    end)
end)

-- **📩 Event: Jahreszeit und Temperatur an Spieler senden**
RegisterServerEvent("requestSeasonAndTemperature")
AddEventHandler("requestSeasonAndTemperature", function()
    local playerId = source
    local season = GetSeason()
    local temperature = GetTemperature()
    
    TriggerClientEvent("receiveSeasonAndTemperature", playerId, season, temperature)
end)

-- **🖥 Serverstatus abrufen**
function GetServerStatus()
    return "online"
end

-- **🌳 Jahreszeit abrufen**
function GetSeason()
    local month = GetCurrentMonth()
    if month >= 3 and month <= 5 then
        return "Frühling"
    elseif month >= 6 and month <= 8 then
        return "Sommer"
    elseif month >= 9 and month <= 11 then
        return "Herbst"
    else
        return "Winter"
    end
end

-- **🌡 Temperatur abrufen**
function GetTemperature()
    local season = GetSeason()
    if season == "Sommer" then
        return math.random(25, 35)
    elseif season == "Winter" then
        return math.random(-5, 5)
    else
        return math.random(10, 20)
    end
end

-- **📅 Aktuellen Monat abrufen**
function GetCurrentMonth()
    return os.date("*t").month
end
