-- Konfiguration
local exemptModels = Config.ExemptNPCs  -- NPCs, die nicht entfernt werden sollen
local ignorePlayerVehicles = Config.IgnorePlayerVehicles  -- Fahrzeuge von Spielern, die nicht entfernt werden sollen

-- Wildtiere, die doppelt so oft spawnen sollen
local wildlifeModels = {
    "a_c_deer", "a_c_boar", "a_c_coyote", "a_c_mtlion"
}

-- Koordinatenbereich für den Wald in Paleto Bay
local paletoForest = {
    minX = -7000.0, maxX = -100.0,
    minY = 4000.0, maxY = 8000.0
}

-- Funktion zum Überprüfen, ob sich ein NPC im Paleto-Wald befindet
local function isInPaletoForest(x, y)
    return x >= paletoForest.minX and x <= paletoForest.maxX and y >= paletoForest.minY and y <= paletoForest.maxY
end

-- Funktion zum Spawnen von zusätzlichen Wildtieren
local function spawnExtraWildlife()
    for _, model in ipairs(wildlifeModels) do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Überprüfen, ob der Spieler sich im Wald von Paleto befindet
        if isInPaletoForest(playerCoords.x, playerCoords.y) then
            for i = 1, 2 do -- Doppelt so viele Tiere spawnen
                local xOffset = math.random(-50, 50)
                local yOffset = math.random(-50, 50)
                local spawnCoords = vector3(playerCoords.x + xOffset, playerCoords.y + yOffset, playerCoords.z)

                -- Wildtier spawnen
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(10)
                end

                local animal = CreatePed(28, GetHashKey(model), spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)
                TaskWanderStandard(animal, 10.0, 10)
                SetEntityAsMissionEntity(animal, true, true)
                SetModelAsNoLongerNeeded(model)
            end
        end
    end
end

-- Funktion zum Entfernen von NPCs (außer Wildtiere in Paleto)
local function removeNPCs()
    local pedList = GetGamePool('CPed') -- Alle NPCs
    for _, ped in ipairs(pedList) do
        local model = GetEntityModel(ped)
        local x, y, z = table.unpack(GetEntityCoords(ped))

        -- Prüfen, ob NPC ein Wildtier ist und in Paleto Bay gespawnt ist
        if isInPaletoForest(x, y) and table.contains(wildlifeModels, model) then
            -- Wildtiere im Paleto-Wald nicht entfernen
        else
            -- Normale NPCs entfernen, wenn sie nicht in der Ausnahmeliste sind
            if not IsPedAPlayer(ped) then
                local exempt = false
                for _, exemptModel in ipairs(exemptModels) do
                    if model == GetHashKey(exemptModel) then
                        exempt = true
                        break
                    end
                end
                
                if not exempt then
                    SetEntityAsMissionEntity(ped, true, true) -- Setzt NPC als "Mission Entity"
                    DeleteEntity(ped) -- Löscht den NPC sofort
                end
            end
        end
    end
end

-- Funktion zum Entfernen von Fahrzeugen (außer Spielerfahrzeuge)
local function removeVehicles()
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local driverPed = GetPedInVehicleSeat(vehicle, -1)

        -- Überprüfen, ob das Fahrzeug nicht einem Spieler gehört
        if driverPed and not IsPedAPlayer(driverPed) then
            SetEntityAsMissionEntity(vehicle, true, true) -- Setzt Fahrzeug als "Mission Entity"
            DeleteEntity(vehicle) -- Löscht das Fahrzeug sofort
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Alle 10 Sekunden Wildtiere spawnen
        spawnExtraWildlife()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- prevent crashing

        -- Diese Natives müssen jede Sekunde aufgerufen werden, um NPCs und Autos vollständig zu blockieren
        SetVehicleDensityMultiplierThisFrame(0.0) -- Setze Fahrzeugdichte auf 0 
        SetPedDensityMultiplierThisFrame(0.1) -- Setze NPC-Dichte leicht hoch (damit Tiere spawnen können)
        SetRandomVehicleDensityMultiplierThisFrame(0.0) -- Setze zufällige Fahrzeuge auf 0
        SetParkedVehicleDensityMultiplierThisFrame(0.0) -- Setze geparkte Fahrzeuge auf 0
        SetScenarioPedDensityMultiplierThisFrame(0.1, 0.1) -- Erhöhe Wildtier-Spawnrate leicht
        SetGarbageTrucks(false) -- Stoppe Müllwagen von zufällig erscheinenden
        SetRandomBoats(false) -- Stoppe zufällige Boote von erscheinen
        SetCreateRandomCops(false) -- Deaktiviere zufällige Polizisten, die herumlaufen/fahren
        SetCreateRandomCopsNotOnScenarios(false) -- Stoppe zufällige Polizisten außerhalb von Szenarien
        SetCreateRandomCopsOnScenarios(false) -- Stoppe zufällige Polizisten in Szenarien
        
        -- Entferne Fahrzeuge aus dem Umkreis des Spielers (1000 Meter)
        local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
        ClearAreaOfVehicles(x, y, z, 1000, false, false, false, false, false)
        RemoveVehiclesFromGeneratorsInArea(x - 500.0, y - 500.0, z - 500.0, x + 500.0, y + 500.0, z + 500.0)

        -- Entferne NPCs in einem riesigen Umkreis
        removeNPCs()

        -- Entferne nur NPC-Fahrzeuge, aber behalte Spielerfahrzeuge
        removeVehicles()
    end
end)

-- Funktion zum Überprüfen, ob ein Wert in einer Tabelle existiert
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end