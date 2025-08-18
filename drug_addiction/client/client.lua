local addictionLevel = 0
local playerPed = PlayerPedId()

-- 📌 Funktion: Suchtlevel vom Server abrufen
RegisterNetEvent('drug_addiction:updateLevel')
AddEventHandler('drug_addiction:updateLevel', function(level)
    addictionLevel = level
end)

-- 📌 Funktion: Droge konsumieren
function useDrug(drug)
    local drugData = Config.Drugs[drug]
    if not drugData then return end 

    -- Animation & Effekt starten
    TriggerEvent('drug_addiction:applyEffects', drug)

    -- Berechnung des neuen Suchtlevels
    addictionLevel = addictionLevel + drugData.addictionRate
    if addictionLevel > Config.MaxAddictionLevel then
        addictionLevel = Config.MaxAddictionLevel
    end

    -- Neues Level an den Server senden
    TriggerServerEvent('drug_addiction:setLevel', addictionLevel)
end

-- 📌 Event-Listener für Drogeneinnahme (von anderen Scripts nutzbar)
RegisterNetEvent('drug_addiction:useDrug')
AddEventHandler('drug_addiction:useDrug', function(drug)
    useDrug(drug)
end)

-- 📌 Funktion: Entzugserscheinungen anwenden
function applyWithdrawalEffects()
    if addictionLevel >= Config.WithdrawalStartLevel then
        -- 📌 Entzugserscheinungen anzeigen (z.B. verschwommenes Sehen, langsame Bewegungen, Zittern)
        SetTimecycleModifier("blur")
        SetTimecycleModifierStrength(0.5)
        -- Weitere Entzugserscheinungen wie Zittern und langsame Bewegungen hier hinzufügen

        -- Beispiel für langsame Bewegungen (kann angepasst werden)
        SetEntityInvincible(playerPed, true)  -- Beispiel: Bewegungseinschränkung bei Sucht
        -- Weitere Anpassungen für den Entzugszustand
    end
end

-- 📌 Event-Listener für Entzugserscheinungen anwenden
RegisterNetEvent('drug_addiction:applyWithdrawalEffects')
AddEventHandler('drug_addiction:applyWithdrawalEffects', function()
    applyWithdrawalEffects()
end)

-- 📌 Automatischer Entzugscheck (jede Minute)
CreateThread(function()
    while true do
        Wait(60000) -- 1 Minute  
        if addictionLevel >= Config.WithdrawalStartLevel then
            TriggerEvent('drug_addiction:applyWithdrawalEffects')
        end
    end
end)

-- 📌 Funktion: Drogeneffekte anwenden (z.B. Halluzinationen)
RegisterNetEvent('drug_addiction:applyEffects')
AddEventHandler('drug_addiction:applyEffects', function(drug)
    local drugData = Config.Drugs[drug]
    if not drugData then return end 

    -- 📌 Beispiel für Drogeneffekte (kann angepasst werden je nach Droge)
    if drug == "cocaine" then
        -- Beispiel für eine schnelle Euphorie-Effekte
        SetEntityInvincible(playerPed, false)
        -- Weitere Effekte wie verbesserte Geschwindigkeit oder Wahrnehmung hier hinzufügen
    elseif drug == "heroin" then
        -- Beispiel für heroinspezifische Halluzinationen
        SetTimecycleModifier("spectator5")
        SetTimecycleModifierStrength(0.3)
    elseif drug == "meth" then
        -- Meth-Spezifische Effekte (z.B. gesteigerte Aggression, schnelle Bewegung)
        SetEntityInvincible(playerPed, true)
    elseif drug == "weed" then
        -- Cannabis Effekte (z.B. langsame Bewegungen und verschwommene Sicht)
        SetTimecycleModifier("fog")
        SetTimecycleModifierStrength(0.2)
    end
end)

-- 📌 Event: Auf Drogenkonsum reagieren
RegisterNetEvent('drug_addiction:useDrug')
AddEventHandler('drug_addiction:useDrug', function(drug)
    useDrug(drug)
end)
