-- server/postman.lua

-- Tabelle zum Speichern der Kleidung der Spieler
local playerClothing = {}

-- Funktion zum Annehmen des Postboten-Jobs
RegisterServerEvent("postsystem:acceptPostmanJob")
AddEventHandler("postsystem:acceptPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Speichere die aktuelle Kleidung des Spielers
    TriggerClientEvent("postsystem:saveCurrentClothing", src)

    -- Setze den Job des Spielers auf Postbote
    player.setJob(Config.PostmanJob.JobName, 0) -- 0 ist der Rang (z. B. Anfänger)

    -- Uniform anziehen
    TriggerClientEvent("postsystem:setPostmanUniform", src)

    -- Benachrichtigung
    TriggerClientEvent("esx:showNotification", src, "✅ Du bist jetzt ein Postbote!")
end)

-- Event zum Speichern der aktuellen Kleidung
RegisterNetEvent("postsystem:saveCurrentClothing")
AddEventHandler("postsystem:saveCurrentClothing", function()
    local src = source
    local playerPed = PlayerPedId()
    local clothing = {
        tshirt_1 = GetPedDrawableVariation(playerPed, 8),
        tshirt_2 = GetPedTextureVariation(playerPed, 8),
        torso_1 = GetPedDrawableVariation(playerPed, 11),
        torso_2 = GetPedTextureVariation(playerPed, 11),
        arms = GetPedDrawableVariation(playerPed, 3),
        pants_1 = GetPedDrawableVariation(playerPed, 4),
        pants_2 = GetPedTextureVariation(playerPed, 4),
        shoes_1 = GetPedDrawableVariation(playerPed, 6),
        shoes_2 = GetPedTextureVariation(playerPed, 6)
    }
    playerClothing[src] = clothing -- Speichere die Kleidung in der Tabelle
end)

-- Event zum Anziehen der Uniform
RegisterNetEvent("postsystem:setPostmanUniform")
AddEventHandler("postsystem:setPostmanUniform", function()
    local playerPed = PlayerPedId()
    local gender = IsPedMale(playerPed) and "male" or "female"
    local uniform = Config.PostmanJob.Uniform[gender]

    -- Uniform anziehen
    SetPedComponentVariation(playerPed, 8, uniform.tshirt_1, uniform.tshirt_2, 2) -- T-Shirt
    SetPedComponentVariation(playerPed, 11, uniform.torso_1, uniform.torso_2, 2) -- Oberkörper
    SetPedComponentVariation(playerPed, 3, uniform.arms, 0, 2) -- Arme
    SetPedComponentVariation(playerPed, 4, uniform.pants_1, uniform.pants_2, 2) -- Hose
    SetPedComponentVariation(playerPed, 6, uniform.shoes_1, uniform.shoes_2, 2) -- Schuhe
end)

-- Funktion zum Beenden des Postboten-Jobs
RegisterServerEvent("postsystem:quitPostmanJob")
AddEventHandler("postsystem:quitPostmanJob", function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Setze den Job des Spielers zurück auf den Standard-Job
    player.setJob(Config.DefaultJob.JobName, Config.DefaultJob.Grade)

    -- Normale Kleidung wiederherstellen
    TriggerClientEvent("postsystem:restoreNormalClothing", src)

    -- Benachrichtigung
    TriggerClientEvent("esx:showNotification", src, "🚪 Du hast den Postboten-Job beendet und deine normale Kleidung angezogen.")
end)

-- Event zum Wiederherstellen der normalen Kleidung
RegisterNetEvent("postsystem:restoreNormalClothing")
AddEventHandler("postsystem:restoreNormalClothing", function()
    local src = source
    local playerPed = PlayerPedId()
    local clothing = playerClothing[src] -- Hole die gespeicherte Kleidung

    if clothing then
        -- Normale Kleidung anziehen
        SetPedComponentVariation(playerPed, 8, clothing.tshirt_1, clothing.tshirt_2, 2) -- T-Shirt
        SetPedComponentVariation(playerPed, 11, clothing.torso_1, clothing.torso_2, 2) -- Oberkörper
        SetPedComponentVariation(playerPed, 3, clothing.arms, 0, 2) -- Arme
        SetPedComponentVariation(playerPed, 4, clothing.pants_1, clothing.pants_2, 2) -- Hose
        SetPedComponentVariation(playerPed, 6, clothing.shoes_1, clothing.shoes_2, 2) -- Schuhe

        -- Entferne die gespeicherte Kleidung aus der Tabelle
        playerClothing[src] = nil
    else
        TriggerClientEvent("esx:showNotification", src, "❌ Es wurde keine gespeicherte Kleidung gefunden!")
    end
end)

-- Funktion zum Abrufen des Levels und der XP
function GetPostmanLevel(identifier, callback)
    MySQL.Async.fetchScalar('SELECT level FROM postman_levels WHERE identifier = ?', { identifier }, function(level)
        if level then
            callback(level)
        else
            -- Wenn der Spieler noch keinen Eintrag hat, erstelle einen neuen
            MySQL.Async.execute('INSERT INTO postman_levels (identifier, level, xp) VALUES (?, 1, 0)', { identifier }, function()
                callback(1) -- Standard-Level
            end)
        end
    end)
end

-- Funktion zum Hinzufügen von XP
function AddPostmanXP(identifier, xp)
    MySQL.Async.fetchScalar('SELECT xp FROM postman_levels WHERE identifier = ?', { identifier }, function(currentXP)
        local newXP = currentXP + xp
        MySQL.Async.execute('UPDATE postman_levels SET xp = ? WHERE identifier = ?', { newXP, identifier }, function()
            CheckLevelUp(identifier, newXP)
        end)
    end)
end

-- Funktion zum Überprüfen, ob ein Level-Up erreicht wurde
function CheckLevelUp(identifier, xp)
    for _, levelData in ipairs(Config.PostmanJob.Levels) do
        if xp >= levelData.xpRequired then
            MySQL.Async.execute('UPDATE postman_levels SET level = ? WHERE identifier = ?', { levelData.level, identifier }, function()
                TriggerClientEvent("postsystem:notify", GetPlayerFromIdentifier(identifier), "Du bist jetzt Level " .. levelData.level .. "!")
            end)
        end
    end
end

-- Zustellungen abrufen
RegisterServerEvent("postsystem:fetchDeliveries")
AddEventHandler("postsystem:fetchDeliveries", function()
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]

    GetPostmanLevel(identifier, function(level)
        MySQL.Async.fetchAll('SELECT * FROM mail_queue WHERE delivered = false', {}, function(deliveries)
            local allowedDeliveries = {}

            for _, delivery in ipairs(deliveries) do
                if delivery.delivery_type == "briefe" or (delivery.delivery_type == "pakete" and level >= 5) or (delivery.delivery_type == "illegale_pakete" and level >= 10) then
                    table.insert(allowedDeliveries, delivery)
                end
            end

            TriggerClientEvent("postsystem:startDeliveries", src, allowedDeliveries)
        end)
    end)
end)

-- Zustellung abschließen
RegisterServerEvent("postsystem:completeDelivery")
AddEventHandler("postsystem:completeDelivery", function(deliveryId, deliveryType)
    local src = source
    local identifier = GetPlayerIdentifiers(src)[1]

    -- Belohne den Postboten
    local xpReward = Config.PostmanJob.XPRewards[deliveryType] or 0
    AddPostmanXP(identifier, xpReward)

    MySQL.Async.execute('UPDATE mail_queue SET delivered = true WHERE id = ?', { deliveryId }, function()
        TriggerClientEvent("postsystem:notify", src, "Zustellung abgeschlossen! Du erhälst $" .. Config.PostmanJob.Salary .. " und " .. xpReward .. " XP!")
        AddMoney(src, Config.PostmanJob.Salary)
    end)
end)

-- Funktion zum Hinzufügen von Geld
function AddMoney(playerId, amount)
    -- Hier kannst du deine Geld-Hinzufügen-Logik implementieren
    TriggerClientEvent("postsystem:notify", playerId, "Du hast $" .. amount .. " erhalten!")
end

-- Funktion zum Spawnen eines Postboten-Fahrzeugs
RegisterServerEvent("postsystem:spawnPostmanVehicle")
AddEventHandler("postsystem:spawnPostmanVehicle", function(vehicleModel)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    if not player then return end

    -- Überprüfe, ob der Spieler den Postboten-Job hat
    if player.job.name ~= Config.PostmanJob.JobName then
        TriggerClientEvent("esx:showNotification", src, "❌ Du bist kein Postbote!")
        return
    end

    -- Spawne das Fahrzeug
    TriggerClientEvent("postsystem:spawnVehicle", src, vehicleModel)
end)

-- Funktion zum Abrufen der Fahrzeugliste
ESX.RegisterServerCallback("postsystem:getPostmanVehicles", function(source, cb)
    cb(Config.PostmanJob.Vehicles)
end)