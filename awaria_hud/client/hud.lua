local ESX = exports['es_extended']:getSharedObject()

-- Variablen für HUD-Daten
local health, armor = 100, 0
local addiction = 0
local temperature = 15
local currentSeason = "Frühling"

-- Cache für Hunger, Durst, Stress
local cache = {
    hunger = 100,
    thirst = 100,
    stress = 0
}

-- Funktion, um Status-Werte in Prozent umzuwandeln
local function statusToPct(val)
    return math.floor(val / 100) -- je nach ESX-Status Skala anpassen
end

-- Polling-Funktion für Hunger/Thirst/Stress
local function pollStatuses()
    if GetResourceState('esx_status') ~= 'started' then return end

    TriggerEvent('esx_status:getStatus', 'hunger', function(s)
        if s and s.val then cache.hunger = statusToPct(s.val) end
    end)
    TriggerEvent('esx_status:getStatus', 'thirst', function(s)
        if s and s.val then cache.thirst = statusToPct(s.val) end
    end)
    TriggerEvent('esx_status:getStatus', 'stress', function(s)
        if s and s.val then cache.stress = statusToPct(s.val) end
    end)
end

-- Event-Handler für Drogensucht
RegisterNetEvent('drug_addiction:updateLevel')
AddEventHandler('drug_addiction:updateLevel', function(level)
    addiction = level or 0
end)

-- Thread für Temperatur + Saison vom Server
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        ESX.TriggerServerCallback('weather_seasons:GetCurrentTemperature', function(temp)
            if temp then
                temperature = temp
            end
        end)
        ESX.TriggerServerCallback('weather_seasons:GetCurrentSeason', function(season)
            if season then
                currentSeason = season
            end
        end)
    end
end)

-- Haupt-Thread für Spieler-HUD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= -1 then
            health = GetEntityHealth(playerPed) - 100
            if health < 0 then health = 0 end
            armor = GetPedArmour(playerPed)

            -- Status-Werte pollen
            pollStatuses()

            SendNUIMessage({
                type = "update",
                health = math.floor(health),
                armor = armor,
                hunger = cache.hunger,
                thirst = cache.thirst,
                stress = cache.stress,
                addiction = addiction,
                temperature = math.floor(temperature),
                season = currentSeason
            })
        end
    end
end)

-- Thread für Fahrzeug-HUD
Citizen.CreateThread(function()
    local wasInVehicle = false
    while true do
        Citizen.Wait(250)
        local playerPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)
        local inVehicle = (currentVehicle ~= 0)

        if inVehicle ~= wasInVehicle then
            SendNUIMessage({ type = "showVehicle", show = inVehicle })
            wasInVehicle = inVehicle
        end

        if inVehicle then
            local speed = GetEntitySpeed(currentVehicle) * 3.6
            local fuel = GetVehicleFuelLevel(currentVehicle)
            local engineHealth = GetVehicleEngineHealth(currentVehicle) / 10

            SendNUIMessage({
                type = "updateVehicle",
                speed = math.floor(speed),
                fuel = math.floor(fuel),
                engineHealth = math.floor(engineHealth)
            })
        end
    end
end)

-- HUD verschieben
RegisterNUICallback('moveHUD', function()
    SendNUIMessage({
        type = "moveHUD",
        position = { x = 0.02, y = 0.75 }
    })
end)
