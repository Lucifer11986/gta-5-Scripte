ESX = exports["es_extended"]:getSharedObject()

-- Lade die Konfigurationsdatei und überprüfe, ob sie geladen wurde
local configData = LoadResourceFile(GetCurrentResourceName(), "config.lua")
print(configData)  -- Debugging: Zeige den Inhalt der geladenen Konfiguration

if configData then
    -- Versuche die Konfiguration direkt zu laden
    local success, decodedConfig = pcall(function()
        local chunk = load(configData)  -- Lade den Lua-Code als "chunk"
        if chunk then
            return chunk()  -- Führe den "chunk" aus und gib das Ergebnis zurück
        else
            error("Fehler beim Laden der Konfigurationsdatei")
        end
    end)

    if success then
        Config = decodedConfig
    else
        print("[Oster-Event] Fehler beim Dekodieren der Konfigurationsdatei.")
        return
    end
else
    print("[Oster-Event] Fehler beim Laden der Konfigurationsdatei.")
    return
end

-- Liste der Osterei-Modelle
local eggModels = {
    "core_egg01",
    "core_egg02",
    "core_egg03",
    "core_egg04",
    "core_egg05",
    "core_egg06"
}

-- Funktion zum Abrufen zufälliger Osterei-Positionen
local function getRandomEggLocations(num)
    local randomLocations = {}
    local shuffledLocations = {}

    -- Kopiere alle Positionen in eine neue Liste
    for i, pos in ipairs(Config.EggLocations) do
        table.insert(shuffledLocations, pos)
    end

    -- Mische die Positionen zufällig
    for i = #shuffledLocations, 2, -1 do
        math.randomseed(os.clock())
        math.random(i)
        local j = math.random(1,50)
        shuffledLocations[i], shuffledLocations[j] = shuffledLocations[j], shuffledLocations[i]
    end

    -- Wähle die ersten "num" Positionen aus
    for i = 1, num do
        table.insert(randomLocations, shuffledLocations[i])
    end
    return randomLocations
end

-- Bei Serverstart Positionen zufällig wählen und in der Datenbank speichern
CreateThread(function()
    if #Config.EggLocations > 0 then
        local randomEggLocations = getRandomEggLocations(10) -- Beispiel: Wähle 10 Positionen

        -- Lösche alte Positionen und Blips, falls vorhanden
        exports.oxmysql:executeSync("DELETE FROM easter_eggs_locations", {})

        -- Speichere neue Positionen in der Datenbank
        for _, pos in ipairs(randomEggLocations) do
            exports.oxmysql:insertSync("INSERT INTO easter_eggs_locations (x, y, z) VALUES (?, ?, ?)", {pos.x, pos.y, pos.z})
        end

        print("[Oster-Event] Neue Ostereier-Positionen nach Server-Neustart gesetzt.")
    else
        print("[Oster-Event] Keine Osterei-Standorte zum Setzen gefunden.")
    end
end)

RegisterNetEvent("easter_event:spawnEggs")
AddEventHandler("easter_event:spawnEggs", function()
    local src = source
    -- Lösche alle Blips, die übrig geblieben sind
    TriggerClientEvent("easter_event:removeAllEggBlips", -1)

    -- Lade neue Positionen aus der Datenbank
    local result = exports.oxmysql:executeSync("SELECT * FROM easter_eggs_locations", {})
    if result then
        local newEggLocations = {}
        for _, row in ipairs(result) do
            table.insert(newEggLocations, vector3(row.x, row.y, row.z))
        end
        TriggerClientEvent("easter_event:createEggs", src, newEggLocations, eggModels) -- Modelle mit an den Client übergeben
        print("[Oster-Event] Ostereier-Daten an Client gesendet.")
    else
        print("[Oster-Event] Fehler beim Laden der Ostereier-Positionen aus der Datenbank.")
    end
end)

local foundEggs = {}

-- Lade gefundene Eier aus der Datenbank
CreateThread(function()
    local result = exports.oxmysql:executeSync("SELECT * FROM easter_eggs", {})
    if result then
        for _, row in ipairs(result) do
            foundEggs[row.egg_id] = true
        end
    end
end)

RegisterNetEvent("easter_event:findEgg")
AddEventHandler("easter_event:findEgg", function(eggIndex)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    if foundEggs[eggIndex] then
        TriggerClientEvent("esx:showNotification", src, "❌ Dieses Ei wurde bereits gefunden!")
        return
    end

    foundEggs[eggIndex] = true
    exports.oxmysql:insert("INSERT INTO easter_eggs (egg_id, player_id) VALUES (?, ?)", {eggIndex, xPlayer.identifier})

    -- 🎁 **Belohnungssystem mit Bankeinzahlung**
    local rewardChance = math.random(1, 100)
    if rewardChance <= 70 then
        local amount = math.random(500, 1000)
        xPlayer.addAccountMoney("bank", amount) -- Geld auf Bankkonto
        TriggerClientEvent("esx:showNotification", src, "🥚 Du hast ein Osterei gefunden! (+ $" .. amount .. " auf dein Konto)")
    elseif rewardChance <= 95 then
        xPlayer.addInventoryItem("chocolate", 1) -- Seltenere Belohnung
        TriggerClientEvent("esx:showNotification", src, "🍫 Du hast ein besonderes Osterei gefunden! (+1 Schokolade)")
    else
        xPlayer.addAccountMoney("bank", 5000) -- Goldenes Ei, seltene Belohnung (Bank)
        TriggerClientEvent("esx:showNotification", src, "🎉 Du hast ein Goldenes Ei gefunden! (+5000$ auf dein Konto)")
    end

    -- Synchronisiere gefundene Eier mit allen Spielern
    TriggerClientEvent("easter_event:updateEggs", -1, foundEggs)

    -- Entferne Blip des gefundenen Eies
    TriggerClientEvent("easter_event:removeEggBlip", -1, eggIndex)
end)

-- Sicherstellen, dass die Tabelle in der Datenbank existiert, wenn das Event gestartet wird
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
end)
