RegisterNetEvent("graffiti:openSprayUI")
AddEventHandler("graffiti:openSprayUI", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showMotifs", 
        motifs = Config.SprayMotifs
    })
end)

RegisterNUICallback('selectMotif', function(data, cb)
    local selectedMotif = data.motif
    local selectedColors = data.colors
    TriggerEvent("graffiti:applySpray", selectedMotif, selectedColors)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
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
