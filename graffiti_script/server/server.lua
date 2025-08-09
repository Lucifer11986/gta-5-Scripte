RegisterNetEvent("graffiti:startSpray")
AddEventHandler("graffiti:startSpray", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Überprüfen, ob der Spieler Spraydosen hat
    if xPlayer.getInventoryItem("spraycan").count > 0 then
        -- Wenn der Spieler Spraydosen hat, kann er das Graffiti sprühen
        TriggerClientEvent("graffiti:startSpray", _source)
    else
        TriggerClientEvent("esx:showNotification", _source, "Du hast keine Spraydosen!")
    end
end)

RegisterNetEvent("graffiti:sprayWithColorAndMotiv")
AddEventHandler("graffiti:sprayWithColorAndMotiv", function(position, sprayTechnique, color, motiv)
    -- Server-seitige Logik für Graffiti (z.B. Speicherung der Position oder Verwaltung der Ressourcen)
    print("Spray mit Farbe " .. color .. " und Motiv " .. motiv .. " wurde auf Position " .. position.x .. ", " .. position.y .. ", " .. position.z .. " angewendet.")
end)
