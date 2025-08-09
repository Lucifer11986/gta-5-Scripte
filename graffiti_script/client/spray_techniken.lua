local selectedTechnique = "basic"

RegisterCommand("selectspray", function(_, args)
    selectedTechnique = args[1] or "basic"
    TriggerEvent("esx:showNotification", "Du hast die Technik " .. selectedTechnique .. " gewählt!")
end)

RegisterNetEvent("graffiti:sprayWithTechnique")
AddEventHandler("graffiti:sprayWithTechnique", function()
    local sprayTechnique = Config.SprayTechniques[selectedTechnique]
    if sprayTechnique then
        -- Code für verschiedene Spray-Techniken je nach Auswahl
        if selectedTechnique == "name" then
            -- Nur Name sprühen
        elseif selectedTechnique == "stencil" then
            -- Schablonenspray
        elseif selectedTechnique == "uv" then
            -- UV-Spray
        end
    else
        TriggerEvent("esx:showNotification", "Ungültige Spray-Technik!")
    end
end)
