ESX = exports["es_extended"]:getSharedObject()

math.randomseed(os.time())

local isAutumnEventActive = false
local pumpkinModels = { "prop_pumpkin_01" } -- Placeholder model, user needs to provide actual models
local foundPumpkins = {}

function getAutumnReward()
    local roll = math.random(1, 100)
    local probs = Config.AutumnEvent.RewardProbabilities
    local rewardTier
    if roll <= probs.very_rare then
        rewardTier = "very_rare"
    elseif roll <= probs.very_rare + probs.rare then
        rewardTier = "rare"
    else
        rewardTier = "common"
    end
    local rewards = Config.AutumnEvent.Rewards[rewardTier]
    return rewards[math.random(#rewards)]
end

function getRandomPumpkinLocations(num)
    local randomLocations = {}
    local shuffledLocations = {}
    for i, pos in ipairs(Config.AutumnEvent.PumpkinLocations) do
        table.insert(shuffledLocations, pos)
    end
    for i = #shuffledLocations, 2, -1 do
        local j = math.random(i)
        shuffledLocations[i], shuffledLocations[j] = shuffledLocations[j], shuffledLocations[i]
    end
    local numToGet = math.min(num, #shuffledLocations)
    for i = 1, numToGet do
        table.insert(randomLocations, shuffledLocations[i])
    end
    return randomLocations
end

function StartAutumnEvent()
    if isAutumnEventActive or not Config.AutumnEvent.Enabled then return end
    local result = exports.oxmysql:executeSync("SELECT event_start_time FROM event_timers WHERE event_name = 'autumn'", {})
    local startTime = result and result[1] and result[1].event_start_time
    if startTime then
        if os.time() - startTime > (Config.AutumnEvent.DurationDays * 86400) then
            print("[Herbst-Event] Event-Dauer ist abgelaufen.")
            return
        end
    else
        exports.oxmysql:insertSync("INSERT INTO event_timers (event_name, event_start_time) VALUES ('autumn', ?)", {os.time()})
    end
    isAutumnEventActive = true
    print("[Herbst-Event] Es ist Herbst! Das Kürbis-Event wird gestartet.")
    local locations = getRandomPumpkinLocations(15)
    exports.oxmysql:executeSync("DELETE FROM autumn_pumpkins_locations", {})
    for _, pos in ipairs(locations) do
        exports.oxmysql:insertSync("INSERT INTO autumn_pumpkins_locations (x, y, z) VALUES (?, ?, ?)", {pos.x, pos.y, pos.z})
    end
end

function StopAutumnEvent()
    if not isAutumnEventActive then return end
    isAutumnEventActive = false
    print("[Herbst-Event] Event gestoppt.")
    exports.oxmysql:executeSync("DELETE FROM autumn_pumpkins_locations", {})
    TriggerClientEvent("autumn_event:removeAllPumpkins", -1)
end

RegisterNetEvent('season:updateSeason')
AddEventHandler('season:updateSeason', function(seasonName, temperature)
    if seasonName == "Herbst" then
        StartAutumnEvent()
    else
        StopAutumnEvent()
    end
end)

AddEventHandler("weather_seasons:initialized", function()
    if exports.weather_seasons:GetCurrentSeason() == "Herbst" then
        StartAutumnEvent()
    end
end)

RegisterNetEvent("autumn_event:spawnPumpkins")
AddEventHandler("autumn_event:spawnPumpkins", function()
    if not isAutumnEventActive then return end
    local src = source
    local result = exports.oxmysql:executeSync("SELECT * FROM autumn_pumpkins_locations", {})
    if result then
        local locations = {}
        for _, row in ipairs(result) do
            table.insert(locations, vector3(row.x, row.y, row.z))
        end
        TriggerClientEvent("autumn_event:createPumpkins", src, locations, pumpkinModels)
    end
end)

RegisterNetEvent("autumn_event:findPumpkin")
AddEventHandler("autumn_event:findPumpkin", function(pumpkinIndex)
    if not isAutumnEventActive then return end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if foundPumpkins[pumpkinIndex] then
        TriggerClientEvent("esx:showNotification", src, "❌ Dieser Kürbis wurde bereits gefunden!")
        return
    end
    foundPumpkins[pumpkinIndex] = true
    local reward = getAutumnReward()
    if reward.type == "money" then
        local amount = math.random(reward.amount.min, reward.amount.max)
        xPlayer.addAccountMoney("bank", amount)
        TriggerClientEvent("esx:showNotification", src, "🎃 Du hast einen Kürbis gefunden und $" .. amount .. " erhalten!")
    elseif reward.type == "item" then
        xPlayer.addInventoryItem(reward.name, reward.amount)
        TriggerClientEvent("esx:showNotification", src, "🎃 Du hast einen Kürbis gefunden und " .. reward.amount .. "x " .. reward.name .. " erhalten!")
    end
    TriggerClientEvent("autumn_event:updatePumpkins", -1, foundPumpkins)
    TriggerClientEvent("autumn_event:removePumpkinBlip", -1, pumpkinIndex)
end)

CreateThread(function()
    exports.oxmysql:executeSync("CREATE TABLE IF NOT EXISTS autumn_pumpkins_locations (id INT AUTO_INCREMENT PRIMARY KEY, x FLOAT NOT NULL, y FLOAT NOT NULL, z FLOAT NOT NULL);")
    exports.oxmysql:executeSync("CREATE TABLE IF NOT EXISTS event_timers (event_name VARCHAR(50) PRIMARY KEY, event_start_time INT NOT NULL);")
end)
