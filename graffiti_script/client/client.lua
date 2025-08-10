local selectedColor = "red"
local selectedMotiv = "Motiv 1" -- Default-Motiv

-- Befehl, um Sprayfarbe auszuwählen
RegisterCommand("selectColor", function(_, args)
    selectedColor = args[1] or "red"
    TriggerEvent("esx:showNotification", "Du hast die Farbe " .. Config.Colors[selectedColor] .. " gewählt!")
end)

-- Befehl, um das Motiv auszuwählen
RegisterCommand("selectMotiv", function(_, args)
    selectedMotiv = args[1] or "Motiv 1"
    TriggerEvent("esx:showNotification", "Du hast das Motiv '" .. selectedMotiv .. "' gewählt!")
end)

-- Befehl, um Graffiti zu sprühen
RegisterCommand("spray", function()
    local xPlayer = ESX.GetPlayerData()

    -- Überprüfen, ob der Spieler das Item Spraydose hat
    if xPlayer.getInventoryItem('spraycan').count > 0 then
        TriggerEvent("graffiti:startSpray")
    else
        TriggerEvent("esx:showNotification", "Du hast keine Spraydosen!")
    end
end)

-- Event für den Start des Sprayens
RegisterNetEvent("graffiti:startSpray")
AddEventHandler("graffiti:startSpray", function()
    -- Hier fügst du die Logik ein, um Graffiti zu sprühen.
    -- Der Spieler wählt das Motiv und die Farbe, bevor das Graffiti auf die Wand kommt.
    TriggerEvent("graffiti:sprayWithColorAndMotiv")
end)

-- Event für das Sprühen mit gewählter Farbe und Motiv
RegisterNetEvent("graffiti:sprayWithColorAndMotiv")
AddEventHandler("graffiti:sprayWithColorAndMotiv", function()
    -- Logik für das Sprühen auf der Wand mit der Farbe und dem Motiv des Spielers
    print("Sprühfarbe: " .. Config.Colors[selectedColor] .. ", Motiv: " .. selectedMotiv)
    -- Hier könntest du die Position und das Motiv definieren und in der Welt anzeigen.
end)
