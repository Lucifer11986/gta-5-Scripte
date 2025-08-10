local npcState = true
local vehicleState = true
local safeZones = {}

-- Command für Admins, um Spawning zu steuern
RegisterCommand("toggleSpawning", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin") then
        npcState = not npcState
        vehicleState = not vehicleState

        -- Benachrichtige alle Clients, dass die Spawning-Optionen geändert wurden
        TriggerClientEvent("no_npc:updateStates", -1, npcState, vehicleState)

        -- Chat-Nachricht an alle Spieler senden
        TriggerClientEvent("chat:addMessage", -1, {
            args = {"System", string.format("NPCs: %s, Fahrzeuge: %s", npcState and "Aktiviert" or "Deaktiviert", vehicleState and "Aktiviert" or "Deaktiviert")}
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"System", "Du hast keine Berechtigung, diesen Befehl auszuführen."}
        })
    end
end, false)

-- Command für Admins, um sichere Zonen zu definieren
RegisterCommand("setSafeZone", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin") then
        local radius = tonumber(args[1]) or 5000 -- Standardradius: 5000 Einheiten
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)

        -- Sichere Zone in die Tabelle einfügen
        table.insert(safeZones, {coords = coords, radius = radius})

        -- Benachrichtige alle Clients, dass eine neue sichere Zone erstellt wurde
        TriggerClientEvent("updateSafeZones", -1, safeZones)

        -- Chat-Nachricht an alle Spieler senden
        TriggerClientEvent("chat:addMessage", -1, {
            args = {"System", "Sichere Zone wurde erstellt."}
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"System", "Du hast keine Berechtigung, diesen Befehl auszuführen."}
        })
    end
end, false)

-- Event, um die sicheren Zonen an die Clients zu senden
AddEventHandler('no_npc:updateSafeZones', function()
    -- Sicherstellen, dass die sichere Zonen nur an Clients gesendet werden, die berechtigt sind
    TriggerClientEvent("updateSafeZones", -1, safeZones)
end)

-- Befehl zum Abrufen der sicheren Zonen (falls gewünscht für Debugging)
RegisterCommand("getSafeZones", function(source, args, rawCommand)
    local src = source
    if IsPlayerAceAllowed(src, "admin") then
        -- Gebe eine Liste der sicheren Zonen im Chat aus
        for _, zone in ipairs(safeZones) do
            TriggerClientEvent("chat:addMessage", src, {
                args = {"System", string.format("Sichere Zone bei %s mit Radius %d", vector3(zone.coords.x, zone.coords.y, zone.coords.z), zone.radius)}
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = {"System", "Du hast keine Berechtigung, diesen Befehl auszuführen."}
        })
    end
end, false)
