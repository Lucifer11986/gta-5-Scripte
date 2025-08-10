-- Client script for No-NPC, refactored for performance and clarity.

-- Global state variables controlled by the server
local npcState = true
local vehicleState = true
local safeZones = {}

-- Helper function to check if a value exists in a table
local function table_contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Helper function to calculate distance between two vectors
local function GetDistance(vec1, vec2)
    return #(vec1 - vec2)
end

-- #############################################################################
-- ## EVENT HANDLERS (Server Communication)
-- #############################################################################

RegisterNetEvent('no_npc:updateStates')
AddEventHandler('no_npc:updateStates', function(newNpcState, newVehicleState)
    npcState = newNpcState
    vehicleState = newVehicleState
    if Config.DebugMode then
        print(('[no-npc] State updated: NPCs=%s, Vehicles=%s'):format(tostring(npcState), tostring(vehicleState)))
    end
end)

RegisterNetEvent('updateSafeZones')
AddEventHandler('updateSafeZones', function(newSafeZones)
    safeZones = newSafeZones
    if Config.DebugMode then
        print(('[no-npc] Received %d safe zones.'):format(#safeZones))
    end
end)

-- #############################################################################
-- ## CORE FUNCTIONS (NPC/Vehicle Removal & Wildlife Spawning)
-- #############################################################################

-- Check if coordinates are within a safe zone
local function isInSafeZone(coords)
    if not safeZones or #safeZones == 0 then return false end
    for _, zone in ipairs(safeZones) do
        if GetDistance(coords, zone.coords) <= zone.radius then
            return true
        end
    end
    return false
end

-- Removes non-protected NPCs
local function removeNPCs()
    if not npcState then return end -- Disabled by server

    -- Pre-calculate hashes for performance, once
    if not Config.ExemptNPCHashes then
        Config.ExemptNPCHashes = {}
        for _, modelName in ipairs(Config.ExemptNPCs) do
            table.insert(Config.ExemptNPCHashes, GetHashKey(modelName))
        end
    end

    local playerPed = PlayerPedId()
    local peds = GetGamePool('CPed')

    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and ped ~= playerPed then
            local pedCoords = GetEntityCoords(ped)

            if not isInSafeZone(pedCoords) then
                local modelHash = GetEntityModel(ped)
                if not table_contains(Config.ExemptNPCHashes, modelHash) then
                    DeleteEntity(ped)
                end
            end
        end
    end
end

-- Removes non-protected vehicles
local function removeVehicles()
    if not vehicleState then return end -- Disabled by server

    -- Pre-calculate hashes for performance, once
    if not Config.AllowedVehicleHashes then
        Config.AllowedVehicleHashes = {}
        for _, modelName in ipairs(Config.AllowedVehicles) do
            table.insert(Config.AllowedVehicleHashes, GetHashKey(modelName))
        end
    end

    local vehicles = GetGamePool('CVehicle')

    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)

            if not isInSafeZone(vehicleCoords) then
                local driver = GetPedInVehicleSeat(vehicle, -1)

                if not (Config.IgnorePlayerVehicles and driver and IsPedAPlayer(driver)) then
                    local modelHash = GetEntityModel(vehicle)
                    if not table_contains(Config.AllowedVehicleHashes, modelHash) then
                        DeleteEntity(vehicle)
                    end
                end
            end
        end
    end
end

-- Spawns additional wildlife
local function spawnWildlife()
    if not Config.SpawnWildlife or not npcState then return end

    local playerCoords = GetEntityCoords(PlayerPedId())

    if GetDistance(playerCoords, Config.WildlifeSpawnArea.center) <= Config.WildlifeSpawnArea.radius then
        local model = Config.WildlifeModels[math.random(#Config.WildlifeModels)]
        local modelHash = GetHashKey(model)

        RequestModel(modelHash)
        local timeout = 1000
        while not HasModelLoaded(modelHash) and timeout > 0 do
            Citizen.Wait(100)
            timeout = timeout - 100
        end

        if HasModelLoaded(modelHash) then
            local spawnCoords = playerCoords + vector3(math.random(-50, 50), math.random(-50, 50), 0)
            local success, z = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 50.0, false)
            if success then
                spawnCoords = vector3(spawnCoords.x, spawnCoords.y, z)
                local animal = CreatePed(28, modelHash, spawnCoords, math.random(0, 360), true, false)
                TaskWanderStandard(animal, 10.0, 10)
                SetEntityAsNoLongerNeeded(animal)
            end
        end
        SetModelAsNoLongerNeeded(modelHash)
    end
end

-- #############################################################################
-- ## MAIN THREADS
-- #############################################################################

-- High-performance loop for frame-by-frame natives
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if npcState then
            SetPedDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        end

        if vehicleState then
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
        end

        SetGarbageTrucks(false)
        SetRandomBoats(false)
        SetCreateRandomCops(false)
    end
end)

-- Slower loop for cleanup of already-spawned entities
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CleanupInterval)
        removeNPCs()
        removeVehicles()
    end
end)

-- Loop for spawning wildlife
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.WildlifeSpawnInterval)
        spawnWildlife()
    end
end)

-- Request initial data from server on startup
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait for server to be ready
    TriggerServerEvent('no_npc:requestInitialData')
end)
