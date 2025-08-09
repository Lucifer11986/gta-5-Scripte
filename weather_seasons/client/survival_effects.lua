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

ESX.RegisterClientCallback('survival:isWearingWarmClothes', function(cb)
    local isWarm = isWearingWarmClothes()
    cb(isWarm)
end)

RegisterNetEvent('survival:requestWarmClothesStatus')
AddEventHandler('survival:requestWarmClothesStatus', function()
    local isWarm = isWearingWarmClothes()
    TriggerServerEvent('survival:responseWarmClothesStatus', isWarm)
end)

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

-- Neu: Health Schaden vom Server empfangen und setzen
RegisterNetEvent('survival:applyHeatDamage')
AddEventHandler('survival:applyHeatDamage', function(damage)
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    local newHealth = currentHealth - damage
    if newHealth < 0 then newHealth = 0 end
    SetEntityHealth(playerPed, newHealth)
end)

RegisterNetEvent('survival:applyFreezingDamage')
AddEventHandler('survival:applyFreezingDamage', function(damage)
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    local newHealth = currentHealth - damage
    if newHealth < 0 then newHealth = 0 end
    SetEntityHealth(playerPed, newHealth)
end)
