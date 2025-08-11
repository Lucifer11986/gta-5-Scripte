local isInHeatwave = false
local heatwaveDuration = 0  -- Dauer der Hitzewelle in Minuten
local thirstMultiplier = 1.5  -- Durstverbrauch wird schneller (1.5x)
local wateringRequired = true  -- Pflanzen müssen häufiger gegossen werden

-- Funktion zum Starten der Hitzewelle
function StartHeatwave()
    isInHeatwave = true
    heatwaveDuration = math.random(15, 30)  -- Zufällige Dauer zwischen 15 und 30 Minuten
    TriggerEvent("notification", "Hitzewelle! Durstverbrauch erhöht und Pflanzen benötigen mehr Wasser!")
    SetTimeout(heatwaveDuration * 60 * 1000, EndHeatwave)  -- Timeout nach der Dauer
end

-- Funktion zum Beenden der Hitzewelle
function EndHeatwave()
    isInHeatwave = false
    TriggerEvent("notification", "Die Hitzewelle ist vorbei. Durstverbrauch normalisiert sich.")
end

-- Überprüfung, ob die Hitzewelle aktiv ist und Durst verbraucht
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- 1 Sekunde warten

        if isInHeatwave then
            -- Durstverbrauch erhöhen (Annahme: es gibt eine globale Durst-Variable)
            local currentThirst = GetPlayerThirst()  -- Muss mit der tatsächlichen Durst-API ersetzt werden
            SetPlayerThirst(currentThirst + thirstMultiplier)
        end
    end
end)

-- Funktion zum Interagieren mit Wasserquellen (z.B. Brunnen oder Pools)
RegisterNetEvent("interact_with_water_source")
AddEventHandler("interact_with_water_source", function()
    if isInHeatwave then
        TriggerEvent("notification", "Du kühlst dich mit Wasser ab!")
        -- Durst verringern oder den Durstverbrauch verlangsamen
        local currentThirst = GetPlayerThirst()
        SetPlayerThirst(currentThirst - 10)  -- Beispiel für Durstsenkung
    else
        TriggerEvent("notification", "Kein Bedarf, sich abzukühlen.")
    end
end)

-- Event für das Starten des Wasser-Battles
RegisterNetEvent("start_water_battle")
AddEventHandler("start_water_battle", function()
    -- Trigger für Wasser-Battle (treffen mit Wasserpistole oder Eimer)
    -- Wird ähnlich wie ein Paintball-Event gehandhabt
    local playerPed = PlayerPedId()
    local waterPistol = CreateWeapon("water_pistol")  -- Funktion für das Erstellen von Wasserpistolen (muss implementiert werden)
    -- Weitere Implementierungen für Trefferzähler und Belohnungen folgen
end)
