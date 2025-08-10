--[[
    Server-Skript für No-NPC
    Komplett refaktorisiert für Performance und Klarheit.
]]

-- Globale Zustandsvariablen
local npcState = true
local vehicleState = true
local safeZones = {} -- Speichert {coords = vector3, radius = float}

-- #############################################################################
-- ## EVENT HANDLER (Kommunikation mit den Clients)
-- #############################################################################

-- Sendet die initialen Daten an einen Client, der sie anfordert
RegisterNetEvent('no_npc:requestInitialData', function()
    local src = source
    TriggerClientEvent('no_npc:updateStates', src, npcState, vehicleState)
    TriggerClientEvent('updateSafeZones', src, safeZones)
    if Config.DebugMode then
        print(('[no-npc] Initialdaten an Client %s gesendet.'):format(src))
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

        -- Benachrichtige alle Clients über die Änderung
        TriggerClientEvent("no_npc:updateStates", -1, npcState, vehicleState)

        -- Sende eine Bestätigungsnachricht an alle
        local statusMsg = string.format("NPC Spawning: %s, Fahrzeug Spawning: %s",
            npcState and "Aktiviert" or "Deaktiviert",
            vehicleState and "Aktiviert" or "Deaktiviert")

        TriggerClientEvent("chat:addMessage", -1, {
            args = {"^2System", statusMsg},
            color = {100, 150, 255}
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^1System", "Du hast keine Berechtigung, diesen Befehl auszuführen. (Benötigt: admin.spawning)"}
        })
    end
end, false)

-- Erstellt eine neue Sicherheitszone am Standort des Admins
RegisterCommand("setSafeZone", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.safezone") then
        local radius = tonumber(args[1]) or 100.0 -- Standardradius: 100 Meter
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)

        table.insert(safeZones, {coords = coords, radius = radius})

        -- Benachrichtige alle Clients über die neue Zone
        TriggerClientEvent("updateSafeZones", -1, safeZones)

        -- Sende eine Bestätigungsnachricht
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^2System", string.format("Sicherheitszone mit Radius %.1f an deiner Position erstellt.", radius)}
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^1System", "Du hast keine Berechtigung, diesen Befehl auszuführen. (Benötigt: admin.safezone)"}
        })
    end
end, false)

-- Löscht alle erstellten Sicherheitszonen
RegisterCommand("clearSafeZones", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.safezone") then
        safeZones = {}

        -- Benachrichtige alle Clients, dass die Zonen gelöscht wurden
        TriggerClientEvent("updateSafeZones", -1, safeZones)

        TriggerClientEvent("chat:addMessage", src, {
            args = {"^2System", "Alle Sicherheitszonen wurden entfernt."}
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^1System", "Du hast keine Berechtigung, diesen Befehl auszuführen. (Benötigt: admin.safezone)"}
        })
    end
end, false)

-- Listet alle aktuellen Sicherheitszonen für den Admin auf
RegisterCommand("getSafeZones", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin.safezone") then
        if #safeZones == 0 then
            TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Es sind keine Sicherheitszonen definiert."}})
            return
        end

        TriggerClientEvent("chat:addMessage", src, { args = {"^2System", "Aktive Sicherheitszonen:"}})
        for i, zone in ipairs(safeZones) do
            local coords = zone.coords
            local msg = string.format("- Zone %d: Radius %.1f bei (%.1f, %.1f, %.1f)", i, zone.radius, coords.x, coords.y, coords.z)
            TriggerClientEvent("chat:addMessage", src, { args = {"", msg} })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"^1System", "Du hast keine Berechtigung, diesen Befehl auszuführen. (Benötigt: admin.safezone)"}
        })
    end
end, false)

-- Hinweis: Um die Befehle zu nutzen, benötigen Admins die ACE-Permissions "admin.spawning" und/oder "admin.safezone"
-- Beispiel für server.cfg:
-- add_ace group.admin admin.spawning allow
-- add_ace group.admin admin.safezone allow
