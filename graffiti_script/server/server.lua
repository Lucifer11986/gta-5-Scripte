RegisterNetEvent("graffiti:startSpray")
AddEventHandler("graffiti:startSpray", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Überprüfen, ob der Spieler eine Spraydose hat
    local hasSpraycan = false
    for i=1, #xPlayer.inventory, 1 do
        if string.find(xPlayer.inventory[i].name, "spraycan_") and xPlayer.inventory[i].count > 0 then
            hasSpraycan = true
            break
        end
    end

    if hasSpraycan then
        -- Wenn der Spieler eine Spraydose hat, kann er das Graffiti sprühen
        TriggerClientEvent("graffiti:startSpray", _source)
    else
        TriggerClientEvent("esx:showNotification", _source, "Du hast keine Spraydosen!")
    end
end)

