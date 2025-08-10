--[[
    Server-Skript für No-NPC
    Komplett refaktorisiert für Performance und Klarheit.
]]

-- Globale Zustandsvariablen
local npcState = true
local vehicleState = true
local safeZones = {} -- Speichert {coords = vector3, radius = float}
local protectedVehicles = {} -- Speichert netId = true für geschützte Fahrzeuge

-- #############################################################################
-- ## HELPER FUNCTIONS
-- #############################################################################

-- Sendet die Liste der geschützten Fahrzeuge an alle Clients
local function syncProtectedVehicles()
    TriggerClientEvent('no_npc:syncProtectedVehicles', -1, protectedVehicles)
    if Config.DebugMode then
        local count = 0
        for _ in pairs(protectedVehicles) do count = count + 1 end
        print(('[no-npc] Geschützte Fahrzeugliste an Clients synchronisiert. Anzahl: %d'):format(count))
    end
end

-- #############################################################################
-- ## EXPORTS (für andere Ressourcen)
-- #############################################################################

-- Markiert ein Fahrzeug als geschützt. Erwartet eine Netzwerk-ID.
-- Verwendung durch andere Skripte: exports.no_npc:protectVehicle(NetworkGetNetworkIdFromEntity(vehicle))
exports('protectVehicle', function(netId)
    if type(netId) ~= 'number' or netId == 0 then return end
    protectedVehicles[netId] = true
    syncProtectedVehicles()
    if Config.DebugMode then
        print(('[no-npc] Fahrzeug mit NetID %d wurde geschützt.'):format(netId))
    end
end)

-- Entfernt den Schutzstatus von einem Fahrzeug. Erwartet eine Netzwerk-ID.
-- Verwendung durch andere Skripte: exports.no_npc:unprotectVehicle(NetworkGetNetworkIdFromEntity(vehicle))
exports('unprotectVehicle', function(netId)
    if type(netId) ~= 'number' or netId == 0 then return end
    if protectedVehicles[netId] then
        protectedVehicles[netId] = nil
        syncProtectedVehicles()
        if Config.DebugMode then
            print(('[no-npc] Schutz für Fahrzeug mit NetID %d wurde aufgehoben.'):format(netId))
        end
    end
end)


-- #############################################################################
-- ## EVENT HANDLER & THREADS
-- #############################################################################

-- Sendet die initialen Daten an einen Client, der sie anfordert
RegisterNetEvent('no_npc:requestInitialData', function()
    local src = source
    TriggerClientEvent('no_npc:updateStates', src, npcState, vehicleState)
    TriggerClientEvent('updateSafeZones', src, safeZones)
    TriggerClientEvent('no_npc:syncProtectedVehicles', src, protectedVehicles)
    TriggerClientEvent('no_npc:syncTime', src, os.date("*t").hour)
    if Config.DebugMode then
        print(('[no-npc] Initialdaten an Client %s gesendet.'):format(src))
    end
end)

-- Thread, der die reale Uhrzeit an die Clients synchronisiert
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Jede Minute
        TriggerClientEvent('no_npc:syncTime', -1, os.date("*t").hour)
    end
end)

-- Thread, um die Liste der geschützten Fahrzeuge von despawnten Entitäten zu säubern
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- Alle 5 Minuten

        local cleanedCount = 0
        for netId, _ in pairs(protectedVehicles) do
            if not NetworkDoesEntityExistWithNetworkId(netId) then
                protectedVehicles[netId] = nil
                cleanedCount = cleanedCount + 1
            end
        end

        if cleanedCount > 0 then
            if Config.DebugMode then
                print(('[no-npc] %d despawnte Fahrzeuge aus der Schutzliste entfernt.'):format(cleanedCount))
            end
            syncProtectedVehicles() -- Synchronisiere die bereinigte Liste mit den Clients
        end
    end
end)


-- #############################################################################
-- ## ADMIN BEFEHLE
-- #############################################################################

-- Schaltet das Spawnen von NPCs und Fahrzeugen global um
RegisterCommand("toggleSpawning", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.spawning") then
        npcState = not npcState
        vehicleState = not vehicleState
        TriggerClientEvent("no_npc:updateStates", -1, npcState, vehicleState)
        local statusMsg = string.format("NPC Spawning: %s, Fahrzeug Spawning: %s", npcState and "Aktiviert" or "Deaktiviert", vehicleState and "Aktiviert" or "Deaktiviert")
        TriggerClientEvent("chat:addMessage", -1, { args = {"^2System", statusMsg}, color = {100, 150, 255} })
    else
        TriggerClientEvent("chat:addMessage", src, { args = {"^1System", "Du hast keine Berechtigung. (Benötigt: admin.spawning)"} })
    end
end, false)

-- Erstellt eine neue Sicherheitszone
RegisterCommand("setSafeZone", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.safezone") then
        local radius = tonumber(args[1]) or 100.0
        local coords = GetEntityCoords(GetPlayerPed(src))
        table.insert(safeZones, {coords = coords, radius = radius})
        TriggerClientEvent("updateSafeZones", -1, safeZones)
        TriggerClientEvent("chat:addMessage", src, { args = {"^2System", string.format("Sicherheitszone mit Radius %.1f erstellt.", radius)} })
    else
        TriggerClientEvent("chat:addMessage", src, { args = {"^1System", "Du hast keine Berechtigung. (Benötigt: admin.safezone)"} })
    end
end, false)

-- Löscht alle Sicherheitszonen
RegisterCommand("clearSafeZones", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.safezone") then
        safeZones = {}
        TriggerClientEvent("updateSafeZones", -1, safeZones)
        TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Alle Sicherheitszonen wurden entfernt."} })
    else
        TriggerClientEvent("chat:addMessage", src, { args = {"^1System", "Du hast keine Berechtigung. (Benötigt: admin.safezone)"} })
    end
end, false)

-- Listet alle Sicherheitszonen auf
RegisterCommand("getSafeZones", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.safezone") then
        if #safeZones == 0 then
            TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Es sind keine Sicherheitszonen definiert."}})
            return
        end
        TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Aktive Sicherheitszonen:"}})
        for i, zone in ipairs(safeZones) do
            local msg = string.format("- Zone %d: Radius %.1f bei (%.1f, %.1f, %.1f)", i, zone.radius, zone.coords.x, zone.coords.y, zone.coords.z)
            TriggerClientEvent("chat:addMessage", src, { args = {"", msg} })
        end
    else
        TriggerClientEvent("chat:addMessage", src, { args = {"^1System", "Du hast keine Berechtigung. (Benötigt: admin.safezone)"} })
    end
end, false)
