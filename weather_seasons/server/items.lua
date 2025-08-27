ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- CONFIG
local REQUIRED_ITEM_NAME = "snow_chains"
local DURABILITY_MIN = 15
local DURABILITY_MAX = 30
-- ENDE CONFIG

local function ApplyChains(source, vehicle)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not vehicle then return end
    local vehicleClass = GetVehicleClass(vehicle)
    local requiredChains = 0
    if vehicleClass >= 0 and vehicleClass <= 7 then
        requiredChains = 2
    elseif vehicleClass == 8 or vehicleClass == 9 then
        requiredChains = (vehicleClass == 8) and 2 or 1
    elseif vehicleClass >= 10 and vehicleClass <= 13 or vehicleClass == 16 then
        requiredChains = (vehicleClass == 16) and 3 or 2
    else
        xPlayer.showNotification("~r~An diesem Fahrzeugtyp können keine Schneeketten angebracht werden.")
        return
    end
    local currentChains = xPlayer.getInventoryItem(REQUIRED_ITEM_NAME).count
    if currentChains < requiredChains then
        xPlayer.showNotification("~r~Du hast nicht genügend Schneeketten. Du benötigst " .. requiredChains .. " Stück.")
        return
    end
    local durability = math.random(DURABILITY_MIN, DURABILITY_MAX)
    Entity(vehicle).state:set("snow_chains_active", true, true)
    Entity(vehicle).state:set("snow_chains_durability", durability, true)
    Entity(vehicle).state:set("snow_chains_installer", source, true)
    xPlayer.removeInventoryItem(REQUIRED_ITEM_NAME, requiredChains)
    xPlayer.showNotification("~g~Du hast " .. requiredChains .. " Schneeketten montiert. Haltbarkeit: " .. durability .. " Minuten.")
    TriggerClientEvent('weather_seasons:updateVehicleState', -1, NetworkGetNetworkIdFromEntity(vehicle), true, durability)
end

RegisterNetEvent('weather_seasons:useSnowChains', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or GetPedInVehicleSeat(vehicle, -1) ~= ped then
        xPlayer.showNotification("~r~Du musst dafür in einem Fahrzeug sitzen.")
        return
    end
    if Entity(vehicle).state.snow_chains_active then
        xPlayer.showNotification("~r~An diesem Fahrzeug sind bereits Schneeketten montiert.")
        return
    end
    local currentSeason = exports.weather_seasons:getCurrentSeason()
    if currentSeason.name ~= "Winter" then
        xPlayer.showNotification("~r~Schneeketten können nur im Winter montiert werden.")
        TriggerClientEvent('weather_seasons:burstTyres', source, NetworkGetNetworkIdFromEntity(vehicle))
        xPlayer.removeInventoryItem(REQUIRED_ITEM_NAME, 1)
        return
    end
    ApplyChains(source, vehicle)
end)

-- KORRIGIERTER BEREICH
RegisterNetEvent('weather_seasons:removeChainsServer', function(vehicleNetId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Direkt mit der Network ID auf die Entität auf dem Server zugreifen
    local vehicleEntity = Entity(vehicleNetId)

    -- Sicherheitsprüfung
    local installerPlayerId = vehicleEntity.state.snow_chains_installer
    if source ~= installerPlayerId and xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification("~r~Nur die Person, die die Ketten montiert hat, kann sie entfernen.")
        return
    end

    vehicleEntity.state:set("snow_chains_active", false, true)
    vehicleEntity.state:set("snow_chains_durability", 0, true)
    vehicleEntity.state:set("snow_chains_installer", nil, true)
    xPlayer.showNotification("~g~Du hast die Schneeketten entfernt.")
    TriggerClientEvent('weather_seasons:updateVehicleState', -1, vehicleNetId, false, 0)
end)
