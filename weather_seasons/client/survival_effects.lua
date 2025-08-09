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

-- Event für die große Benachrichtigung beim Jahreszeitenwechsel
RegisterNetEvent('season:notifySeasonChange')
AddEventHandler('season:notifySeasonChange', function(seasonName)
    local title = "Die Jahreszeit hat gewechselt"
    local message = "Willkommen im ~y~" .. seasonName .. "~s~!"
    local icon = "CHAR_CALENDAR" -- Kalender-Icon

    -- Nutze eine große, zentrierte Benachrichtigung
    ESX.ShowAdvancedNotification(title, "Wetter-Update", message, icon, 1)
end)

-- Debug-Befehl, um die aktuelle Kleidungs-ID zu erhalten
RegisterCommand('myclothes', function()
    local playerPed = PlayerPedId()
    print("--- Aktuelle Kleidung ---")
    -- Component IDs: 3 = Arme, 4 = Hosen, 8 = T-Shirt, 11 = Jacke/Torso
    local components = {3, 4, 8, 11}
    for _, componentId in ipairs(components) do
        local drawableId = GetPedDrawableVariation(playerPed, componentId)
        local textureId = GetPedTextureVariation(playerPed, componentId)
        print("Component " .. componentId .. ": Drawable = " .. drawableId .. ", Texture = " .. textureId)
    end
    print("-------------------------")
    ESX.ShowNotification("Deine aktuellen Kleidungs-IDs wurden in der F8-Konsole ausgegeben.")
end, false) -- false = kann von jedem genutzt werden
