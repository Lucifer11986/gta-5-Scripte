-- This event is triggered from the server when a player uses a spray can item.
RegisterNetEvent("graffiti:useSpray")
AddEventHandler("graffiti:useSpray", function(color)
    -- When a spray can is used, we open the NUI to select a motif.
    -- We pass the color of the used spray can to the UI.
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        motifs = Config.Motives, -- Corrected variable name from Config.SprayMotifs
        color = color
    })
end)

RegisterNUICallback('selectMotif', function(data, cb)
    local selectedMotif = data.motif
    local color = data.color

    -- We now have the motif and color, let's trigger the event to actually place the graffiti
    -- The server expects the arguments in the order: color, motif.
    TriggerServerEvent("graffiti:applySpray", color, selectedMotif)

    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)


-- The old UI systems below are kept for reference but are not used in the main flow anymore.

RegisterNetEvent("graffiti:openSprayUI")
AddEventHandler("graffiti:openSprayUI", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "show",
        motifs = Config.Motives -- Corrected variable name
    })
end)

RegisterNetEvent("graffiti:openUI")
AddEventHandler("graffiti:openUI", function(color)
    local elements = {
        {label = "Tag 1", value = "tag1"},
        {label = "Tag 2", value = "tag2"},
        {label = "Street Art", value = "streetart"},
        {label = "Custom", value = "custom"}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'graffiti_menu',
    {
        title = "Graffiti auswählen",
        align = "top-left",
        elements = elements
    }, function(data, menu)
        local selectedGraffiti = data.current.value
        TriggerServerEvent("graffiti:checkSpray", selectedGraffiti, color)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end)
