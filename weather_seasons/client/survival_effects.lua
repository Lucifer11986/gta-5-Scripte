ESX = exports["es_extended"]:getSharedObject()

local isFreezing = false

function isWearingWarmClothes()
    local playerPed = PlayerPedId()
    local jacketId = GetPedDrawableVariation(playerPed, 11)
    if Config.WarmClothing.jackets[jacketId] then
        return true
    end
    return false
end

-- NEU: Funktion, um zu prüfen, ob der Spieler geschützt ist
function isSheltered()
    local playerPed = PlayerPedId()

    -- Prüfe, ob Spieler in einem Interior ist
    if GetInteriorFromEntity(playerPed) ~= 0 then
        return true
    end

    -- Prüfe, ob Spieler in einem Fahrzeug ist (aber nicht Motorrad)
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleClass = GetVehicleClass(vehicle)
        
        -- Klassen 8 (Motorräder), 13 (Fahrräder), 14 (Boote), 15 (Helis), 16 (Flugzeuge) bieten keinen Schutz
        if vehicleClass == 8 or vehicleClass == 13 or vehicleClass == 14 or vehicleClass == 15 or vehicleClass == 16 then
            return false
        else
            return true
        end
    end

    return false -- Nicht geschützt
end

-- Server fordert den Client auf, den Status zu prüfen
RegisterNetEvent('survival:checkClothingAndApplyEffects')
AddEventHandler('survival:checkClothingAndApplyEffects', function(temperature)
    local isWarm = isWearingWarmClothes()
    local sheltered = isSheltered()
    -- Sende beide Informationen zurück an den Server
    TriggerServerEvent('survival:applyEffects', isWarm, sheltered, temperature)
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
    SetEntityHealth(playerPed, currentHealth - damage)
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