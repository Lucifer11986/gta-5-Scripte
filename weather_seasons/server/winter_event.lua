ESX = exports["es_extended"]:getSharedObject()

math.randomseed(os.time())

local isWinterEventActive = false
local presentModels = { "prop_xmas_present_01" } -- Placeholder model
local foundPresents = {}

function getWinterReward()
    local roll = math.random(1, 100)
    local probs = Config.WinterEvent.RewardProbabilities
    local rewardTier

    if roll <= probs.very_rare then
        rewardTier = "very_rare"
    elseif roll <= probs.very_rare + probs.rare then
        rewardTier = "rare"
    else
        rewardTier = "common"
    end

    local rewards = Config.WinterEvent.Rewards[rewardTier]
    local chosenReward = rewards[math.random(#rewards)]
    return chosenReward
end

function getRandomPresentLocations(num)
    local randomLocations = {}
    local shuffledLocations = {}
    for i, pos in ipairs(Config.WinterEvent.PresentLocations) do
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

function StartWinterEvent()
    if isWinterEventActive or not Config.WinterEvent.Enabled then return end

    local result = exports.oxmysql:executeSync("SELECT event_start_time FROM event_timers WHERE event_name = 'winter'", {})
    local startTime = result and result[1] and result[1].event_start_time

    if startTime then
        local durationSeconds = Config.WinterEvent.DurationDays * 24 * 60 * 60
        if os.time() - startTime > durationSeconds then
            print("[Winter-Event] Event-Dauer ist abgelaufen.")
            return
        end
    else
        exports.oxmysql:insertSync("INSERT INTO event_timers (event_name, event_start_time) VALUES ('winter', ?)", {os.time()})
    end

    isWinterEventActive = true
    print("[Winter-Event] Es ist Winter! Das Geschenk-Event wird gestartet.")

    local locations = getRandomPresentLocations(15)
    exports.oxmysql:executeSync("DELETE FROM winter_presents_locations", {})
    for _, pos in ipairs(locations) do
        exports.oxmysql:insertSync("INSERT INTO winter_presents_locations (x, y, z) VALUES (?, ?, ?)", {pos.x, pos.y, pos.z})
    end
    print("[Winter-Event] Neue Geschenk-Positionen gesetzt.")
end

function StopWinterEvent()
    if not isWinterEventActive then return end
    isWinterEventActive = false
    print("[Winter-Event] Event gestoppt.")
    exports.oxmysql:executeSync("DELETE FROM winter_presents_locations", {})
    TriggerClientEvent("winter_event:removeAllPresents", -1)
end

RegisterNetEvent('season:updateSeason')
AddEventHandler('season:updateSeason', function(seasonName, temperature)
    if seasonName == "Winter" then
        StartWinterEvent()
    else
        StopWinterEvent()
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    if exports.weather_seasons:GetCurrentSeason() == "Winter" then
        StartWinterEvent()
    end
end)

RegisterNetEvent("winter_event:spawnPresents")
AddEventHandler("winter_event:spawnPresents", function()
    if not isWinterEventActive then return end
    local src = source
    local result = exports.oxmysql:executeSync("SELECT * FROM winter_presents_locations", {})
    if result then
        local locations = {}
        for _, row in ipairs(result) do
            table.insert(locations, vector3(row.x, row.y, row.z))
        end
        TriggerClientEvent("winter_event:createPresents", src, locations, presentModels)
    end
end)

RegisterNetEvent("winter_event:findPresent")
AddEventHandler("winter_event:findPresent", function(presentIndex)
    if not isWinterEventActive then return end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if foundPresents[presentIndex] then
        TriggerClientEvent("esx:showNotification", src, "❌ Dieses Geschenk wurde bereits gefunden!")
        return
    end

    foundPresents[presentIndex] = true

    local reward = getWinterReward()
    if reward.type == "money" then
        local amount = math.random(reward.amount.min, reward.amount.max)
        xPlayer.addAccountMoney("bank", amount)
        TriggerClientEvent("esx:showNotification", src, "🎁 Du hast ein Geschenk gefunden und $" .. amount .. " erhalten!")
    elseif reward.type == "item" then
        xPlayer.addInventoryItem(reward.name, reward.amount)
        TriggerClientEvent("esx:showNotification", src, "🎁 Du hast ein Geschenk gefunden und " .. reward.amount .. "x " .. reward.name .. " erhalten!")
    end

    TriggerClientEvent("winter_event:updatePresents", -1, foundPresents)
    TriggerClientEvent("winter_event:removePresentBlip", -1, presentIndex)
end)

CreateThread(function()
    exports.oxmysql:executeSync([[
        CREATE TABLE IF NOT EXISTS winter_presents_locations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            x FLOAT NOT NULL,
            y FLOAT NOT NULL,
            z FLOAT NOT NULL
        );
    ]])
end)
