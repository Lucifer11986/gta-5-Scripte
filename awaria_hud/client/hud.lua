local ESX = exports['es_extended']:getSharedObject()
local temperature = 15 -- Standardwert setzen

-- Temperatur regelmäßig vom Server abrufen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Temperatur nur alle 10 Sekunden abrufen (Performance-Optimierung)
        ESX.TriggerServerCallback("weather:getTemperature", function(temp)
            if temp then
                temperature = temp -- Temperatur speichern, damit sie in der HUD-Schleife aktualisiert wird
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Aktualisierung alle 500ms für flüssigere Werteänderung

        local playerPed = PlayerPedId()
        local health = (GetEntityHealth(playerPed) - 100) / (GetEntityMaxHealth(playerPed) - 100) * 100 -- Normalisiert auf 0-100
        local armor = GetPedArmour(playerPed)

        -- HINWEIS: Die folgenden Exporte hängen von den Skripten ab, die du auf deinem Server verwendest.
        -- Passe die Namen ("needs_script", "drug_script") entsprechend an.
        local hunger = exports["needs_script"]:GetHunger() or 100
        local thirst = exports["needs_script"]:GetThirst() or 100
        local energy = exports["needs_script"]:GetEnergy() or 100
        -- Passe "drug_script" bei Bedarf an den Namen deines Drogen-Skripts an.
        local addiction = exports["drug_script"]:GetAddictionLevel() or 0
        local needs = exports["needs_script"]:GetNeeds() or 100

        SendNUIMessage({
            type = "update",
            health = math.floor(health),
            armor = armor,
            hunger = hunger,
            thirst = thirst,
            energy = energy,
            addiction = addiction,
            needs = needs,
            temperature = temperature -- Aktualisierte Temperatur wird hier verwendet
        })
    end
end)

RegisterNUICallback('moveHUD', function()
    SendNUIMessage({
        type = "moveHUD",
        position = { x = 0.02, y = 0.75 } -- Position höher über die Minimap gesetzt
    })
end)
