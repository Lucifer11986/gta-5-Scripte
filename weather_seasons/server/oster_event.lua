ESX = exports["es_extended"]:getSharedObject()

math.randomseed(os.time())

local isEasterActive = false
local eggModels = { "core_egg01", "core_egg02", "core_egg03", "core_egg04", "core_egg05", "core_egg06" }
local foundEggs = {}

function getRandomEggLocations(num)
    local randomLocations = {}
    local shuffledLocations = {}
    for i, pos in ipairs(Config.EggLocations) do
        table.insert(shuffledLocations, pos)
    end
    for i = #shuffledLocations, 2, -1 do
        local j = math.random(i)
        shuffledLocations[i], shuffledLocations[j] = shuffledLocations[j], shuffledLocations[i]
    end
    for i = 1, num do
        table.insert(randomLocations, shuffledLocations[i])
    end
    return randomLocations
end

function StartEasterEvent()
    if isEasterActive then return end
    isEasterActive = true
    print("[Oster-Event] Es ist Frühling! Das Event wird gestartet.")

    -- Lade bereits gefundene Eier, um sie nicht erneut zu spawnen
    local result = exports.oxmysql:executeSync("SELECT * FROM easter_eggs", {})
    if result then
        for _, row in ipairs(result) do
            foundEggs[row.egg_id] = true
        end
    end

    -- Wähle neue zufällige Positionen und speichere sie
    if #Config.EggLocations > 0 then
        local randomEggLocations = getRandomEggLocations(10)
        exports.oxmysql:executeSync("DELETE FROM easter_eggs_locations", {})
        for _, pos in ipairs(randomEggLocations) do
            exports.oxmysql:insertSync("INSERT INTO easter_eggs_locations (x, y, z) VALUES (?, ?, ?)", {pos.x, pos.y, pos.z})
        end
        print("[Oster-Event] Neue Ostereier-Positionen gesetzt.")
    else
        print("[Oster-Event] Keine Osterei-Standorte zum Setzen gefunden.")
    end
end

function StopEasterEvent()
    if not isEasterActive then return end
    isEasterActive = false
    print("[Oster-Event] Es ist nicht mehr Frühling! Das Event wird gestoppt.")
    -- Lösche die Eier-Positionen aus der Datenbank
    exports.oxmysql:executeSync("DELETE FROM easter_eggs_locations", {})
    -- Benachrichtige alle Clients, die Eier und Blips zu entfernen
    TriggerClientEvent("easter_event:removeAllEggs", -1)
end

-- Event-Handler für die Saison-Änderung
RegisterNetEvent('season:updateSeason')
AddEventHandler('season:updateSeason', function(seasonName, temperature)
    if seasonName == "Frühling" then
        StartEasterEvent()
    else
        StopEasterEvent()
    end
end)

-- Überprüfe die Jahreszeit beim Start der Ressource
Citizen.CreateThread(function()
    Citizen.Wait(2000) -- Warte kurz, damit der Wetter-Export bereit ist
    local currentSeason = exports.weather_seasons:GetCurrentSeason()
    if currentSeason == "Frühling" then
        StartEasterEvent()
    end
end)


RegisterNetEvent("easter_event:spawnEggs")
AddEventHandler("easter_event:spawnEggs", function()
    if not isEasterActive then return end
    local src = source
    TriggerClientEvent("easter_event:removeAllEggBlips", -1)
    local result = exports.oxmysql:executeSync("SELECT * FROM easter_eggs_locations", {})
    if result then
        local newEggLocations = {}
        for _, row in ipairs(result) do
            table.insert(newEggLocations, vector3(row.x, row.y, row.z))
        end
        TriggerClientEvent("easter_event:createEggs", src, newEggLocations, eggModels)
        print("[Oster-Event] Ostereier-Daten an Client gesendet.")
    else
        print("[Oster-Event] Fehler beim Laden der Ostereier-Positionen aus der Datenbank.")
    end
end)

RegisterNetEvent("easter_event:findEgg")
AddEventHandler("easter_event:findEgg", function(eggIndex)
    if not isEasterActive then return end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if foundEggs[eggIndex] then
        TriggerClientEvent("esx:showNotification", src, "❌ Dieses Ei wurde bereits gefunden!")
        return
    end
    foundEggs[eggIndex] = true
    exports.oxmysql:insert("INSERT INTO easter_eggs (egg_id, player_id) VALUES (?, ?)", {eggIndex, xPlayer.identifier})
    local rewardChance = math.random(1, 100)
    if rewardChance <= 70 then
        local amount = math.random(500, 1000)
        xPlayer.addAccountMoney("bank", amount)
        TriggerClientEvent("esx:showNotification", src, "🥚 Du hast ein Osterei gefunden! (+ $" .. amount .. " auf dein Konto)")
    elseif rewardChance <= 95 then
        local itemName = "chocolate"
        local itemCount = 1
        xPlayer.addInventoryItem(itemName, itemCount)
        local itemLabel = ESX.GetItemLabel(itemName)
        TriggerClientEvent("esx:showNotification", src, "🍫 Du hast ein besonderes Osterei gefunden! (+ " .. itemCount .. " " .. itemLabel .. ")")
    else
        xPlayer.addAccountMoney("bank", 5000)
        TriggerClientEvent("esx:showNotification", src, "🎉 Du hast ein Goldenes Ei gefunden! (+5000$ auf dein Konto)")
    end
    TriggerClientEvent("easter_event:updateEggs", -1, foundEggs)
    TriggerClientEvent("easter_event:removeEggBlip", -1, eggIndex)
end)

-- SQL Tabellen Erstellung
CreateThread(function()
    exports.oxmysql:executeSync([[
        CREATE TABLE IF NOT EXISTS easter_eggs_locations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            x FLOAT NOT NULL,
            y FLOAT NOT NULL,
            z FLOAT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])
    exports.oxmysql:executeSync([[
        CREATE TABLE IF NOT EXISTS easter_eggs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            egg_id INT NOT NULL,
            player_id VARCHAR(255) NOT NULL,
            found_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]])
end)
