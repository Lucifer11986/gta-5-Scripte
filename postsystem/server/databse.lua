-- Funktion zum Abrufen der Spielerkoordinaten
function GetPlayerCoords(playerId)
    local player = GetPlayerPed(playerId)
    return GetEntityCoords(player)
end

-- Funktion zum Hinzufügen von Geld
function AddMoney(playerId, amount)
    -- Hier kannst du deine Geld-Hinzufügen-Logik implementieren
    TriggerClientEvent("postsystem:notify", playerId, "Du hast $" .. amount .. " erhalten!")
end