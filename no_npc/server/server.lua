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

-- Markiert ein Fahrzeug als geschützt
exports('protectVehicle', function(vehicle)
    if type(vehicle) ~= 'number' then return end -- Muss eine Entity-ID sein
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and netId ~= 0 then
        protectedVehicles[netId] = true
        syncProtectedVehicles()
        if Config.DebugMode then
            print(('[no-npc] Fahrzeug mit NetID %d wurde geschützt.'):format(netId))
        end
    end
end)

-- Entfernt den Schutzstatus von einem Fahrzeug
exports('unprotectVehicle', function(vehicle)
    if type(vehicle) ~= 'number' then return end -- Muss eine Entity-ID sein
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId and protectedVehicles[netId] then
        protectedVehicles[netId] = nil
        syncProtectedVehicles()
        if Config.DebugMode then
            print(('[no-npc] Schutz für Fahrzeug mit NetID %d wurde aufgehoben.'):format(netId))
        end
    end
end)


-- #############################################################################
-- ## EVENT HANDLER
-- #############################################################################

-- Sendet die initialen Daten an einen Client, der sie anfordert
RegisterNetEvent('no_npc:requestInitialData', function()
    local src = source
    TriggerClientEvent('no_npc:updateStates', src, npcState, vehicleState)
    TriggerClientEvent('updateSafeZones', src, safeZones)
    TriggerClientEvent('no_npc:syncProtectedVehicles', src, protectedVehicles) -- Sende auch die geschützten Fahrzeuge
    if Config.DebugMode then
        print(('[no-npc] Initialdaten an Client %s gesendet.'):format(src))
    end
end)

-- Listener, um die Liste sauber zu halten, wenn eine Entität (z.B. Fahrzeug) vom Spiel entfernt wird
AddEventHandler('entityRemoved', function(entity)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if netId and protectedVehicles[netId] then
        protectedVehicles[netId] = nil
        -- Eine Synchronisierung hier könnte zu viel Last erzeugen, wenn viele Autos despawnen.
        -- Die Liste wird sich mit der Zeit von selbst reinigen.
        if Config.DebugMode then
            print(('[no-npc] Geschütztes Fahrzeug mit NetID %d wurde aus der Liste entfernt, da es despawnt ist.'):format(netId))
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
            TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Es sind keine Sicherheitszonen definiert."} })
            return
        end
        TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Aktive Sicherheitszonen:"} })
        for i, zone in ipairs(safeZones) do
            local msg = string.format("- Zone %d: Radius %.1f bei (%.1f, %.1f, %.1f)", i, zone.radius, zone.coords.x, zone.coords.y, zone.coords.z)
            TriggerClientEvent("chat:addMessage", src, { args = {"", msg} })
        end
    else
        TriggerClientEvent("chat:addMessage", src, { args = {"^1System", "Du hast keine Berechtigung. (Benötigt: admin.safezone)"} })
    end
end, false)