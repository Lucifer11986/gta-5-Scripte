ESX = exports['es_extended']:getSharedObject()

local isFreezing = false

local function isWearingWarmClothes()
    local playerPed = PlayerPedId()
    local jacketId = GetPedDrawableVariation(playerPed, 11)
    if Config.WarmClothing and Config.WarmClothing.jackets and Config.WarmClothing.jackets[jacketId] then
        return true
    end
    return false
end

RegisterNetEvent('survival:requestIsWearingWarmClothes')
AddEventHandler('survival:requestIsWearingWarmClothes', function()
    local warm = isWearingWarmClothes()
    TriggerServerEvent('survival:responseIsWearingWarmClothes', warm)
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

-- Event zum Anwenden von Schaden (wird vom Server ausgelöst)
RegisterNetEvent('survival:applyDamage')
AddEventHandler('survival:applyDamage', function(damage)
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    SetEntityHealth(playerPed, math.max(currentHealth - damage, 0))
end)

-- Event für die große Benachrichtigung beim Jahreszeitenwechsel
RegisterNetEvent('season:notifySeasonChange')
AddEventHandler('season:notifySeasonChange', function(seasonName)
    local title = "Die Jahreszeit hat gewechselt"
    local message = "Willkommen im ~y~" .. seasonName .. "~s~!"
    local icon = "CHAR_CALENDAR"
    ESX.ShowAdvancedNotification(title, "Wetter-Update", message, icon, 1)
end)

-- Debug-Befehl, um die aktuelle Kleidungs-ID zu erhalten
RegisterCommand('myclothes', function()
    local playerPed = PlayerPedId()
    print("--- Aktuelle Kleidung ---")
    local components = {3, 4, 8, 11} 
    for _, componentId in ipairs(components) do
        local drawableId = GetPedDrawableVariation(playerPed, componentId)
        local textureId = GetPedTextureVariation(playerPed, componentId)
        print("Component " .. componentId .. ": Drawable = " .. drawableId .. ", Texture = " .. textureId)
    end
    print("-------------------------")
    ESX.ShowNotification("Deine aktuellen Kleidungs-IDs wurden in der F8-Konsole ausgegeben.")
end, false)
