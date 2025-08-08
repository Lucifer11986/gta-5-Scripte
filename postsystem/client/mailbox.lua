-- Briefkasten platzieren
RegisterCommand("placemailbox", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    -- Briefkasten-Objekt erstellen
    local mailbox = CreateObject(GetHashKey("prop_rub_binbag_01"), coords.x, coords.y, coords.z, true, true, true)

    -- Position in der Datenbank speichern
    TriggerServerEvent("postsystem:placeMailbox", coords, heading)
    TriggerEvent("postsystem:notify", "Briefkasten erfolgreich platziert!")
end)

-- Briefkasten öffnen
RegisterNetEvent("postsystem:openMailbox")
AddEventHandler("postsystem:openMailbox", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Überprüfe, ob der Spieler in der Nähe eines Briefkastens ist
    local mailbox = GetClosestObjectOfType(coords, 2.0, GetHashKey("prop_rub_binbag_01"), false, false, false)
    if mailbox ~= 0 then
        TriggerServerEvent("postsystem:fetchMailbox", GetPlayerServerId(PlayerId()))
    end
end)