ESX = exports["es_extended"]:getSharedObject()

local isFreezing = false

-- Diese Funktion überprüft, ob der Spieler warme Kleidung trägt.
function isWearingWarmClothes()
    local playerPed = PlayerPedId()

    -- Überprüfe die Jacke (Component ID 11)
    local jacketId = GetPedDrawableVariation(playerPed, 11)
    if Config.WarmClothing.jackets[jacketId] then
        return true -- Spieler trägt eine warme Jacke
    end

    -- Hier könnten weitere Checks für Hosen etc. hinzugefügt werden

    return false -- Spieler trägt keine ausreichend warme Kleidung
end

-- Registriere einen Client-Callback, damit der Server den Kleidungsstatus abfragen kann
ESX.RegisterClientCallback('survival:isWearingWarmClothes', function(cb)
    local isWarm = isWearingWarmClothes()
    cb(isWarm)
end)

-- Event, um den visuellen Frier-Effekt zu steuern
RegisterNetEvent('survival:setFreezingEffect')
AddEventHandler('survival:setFreezingEffect', function(shouldBeFreezing)
    if shouldBeFreezing and not isFreezing then
        isFreezing = true
        SetTimecycleModifier("hud_def_colorgrade_ice")
        SetTimecycleModifierStrength(0.4)
    elseif not shouldBeFreezing and isFreezing then
        isFreezing = false
        ClearTimecycleModifier()
    end
end)