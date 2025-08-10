Config = {
    ExemptNPCs = {"a_m_m_skater_01", "U_M_Y_Baygor", "CS_Tom", "S_M_M_Postal_01", "S_M_M_Postal_02", "a_m_y_business_01"}, -- Liste der NPCs, die nicht gelöscht werden
    AllowedVehicles = {"dinghy2", "faggio"}, -- Liste der erlaubten Fahrzeuge
    IgnorePlayerVehicles = true, -- Fahrzeuge von Spielern werden nicht entfernt
    DebugMode = true -- Setze auf 'false', um wieder alle NPCs zu löschen
}

-- Funktion zum Überprüfen, ob ein Wert in einer Tabelle existiert
function table.contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Funktion zum manuellen Spawnen von NPCs
local function spawnNPC(model, x, y, z, heading)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(500)
    end

    local npc = CreatePed(4, model, x, y, z, heading, true, false)
    SetEntityAsMissionEntity(npc, true, true)
    SetModelAsNoLongerNeeded(model)
end

-- Funktion zum Entfernen von NPCs
local function removeNPCs()
    if Config.DebugMode then return end -- Wenn Debug aktiv ist, NPCs nicht entfernen
    
    local pedList = GetGamePool('CPed')
    for _, ped in ipairs(pedList) do
        local model = GetEntityModel(ped)
        
        if not IsPedAPlayer(ped) then
            if not table.contains(Config.ExemptNPCs, GetEntityModel(ped)) then
                DeleteEntity(ped)
            end
        end
    end
end

-- Funktion zum Entfernen von Fahrzeugen
local function removeVehicles()
    if Config.DebugMode then return end
    
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local model = GetEntityModel(vehicle)
        local driverPed = GetPedInVehicleSeat(vehicle, -1)

        -- Fahrzeuge von Spielern oder erlaubte Fahrzeuge werden nicht entfernt
        if not IsPedAPlayer(driverPed) and not table.contains(Config.AllowedVehicles, GetEntityModel(vehicle)) then
            DeleteEntity(vehicle)
        end
    end
end

-- Funktion zum Spawnen von Wildtieren in den Wäldern bei Paleto Bay (doppelte Anzahl)
local function spawnWildlife()
    local wildlifeModels = {"a_c_deer", "a_c_coyote", "a_c_boar"} -- Liste der Wildtiere
    local paletoArea = vector3(-700.0, 5000.0, 50.0) -- Grober Mittelpunkt von Paleto Forest

    for i = 1, 2 do -- Doppelte Anzahl an Wildtieren spawnen
        for _, model in ipairs(wildlifeModels) do
            spawnNPC(GetHashKey(model), paletoArea.x + math.random(-100, 100), paletoArea.y + math.random(-100, 100), paletoArea.z, math.random(0, 360))
        end
    end
end

-- Hauptthread für Entfernung von NPCs & Fahrzeugen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        removeNPCs()
        removeVehicles()
    end
end)

-- Thread für Wildtier-Spawn
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Alle 60 Sekunden Wildtiere spawnen
        spawnWildlife()
    end
end)
