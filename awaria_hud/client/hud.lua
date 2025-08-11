local ESX = exports['es_extended']:getSharedObject()

-- Variablen für HUD-Daten
local hunger = 100
local thirst = 100
local temperature = 15
local addiction = 0

-- Event-Handler für ESX-Status (Hunger/Thirst)
RegisterNetEvent('esx_status:onTick')
AddEventHandler('esx_status:onTick', function(status)
    for i=1, #status, 1 do
        if status[i].name == 'hunger' then
            hunger = status[i].percent
        elseif status[i].name == 'thirst' then
            thirst = status[i].percent
        end
    end
end)

-- Event-Handler für Drug Addiction
RegisterNetEvent('drug_addiction:updateLevel')
AddEventHandler('drug_addiction:updateLevel', function(level)
    addiction = level
end)

-- Thread to get Temperature from server
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000) -- Update every 10 seconds
        ESX.TriggerServerCallback('awaria_hud:getTemperature', function(temp)
            if temp ~= nil then
                temperature = temp
            end
        end)
    end
end)

-- Haupt-Thread für die Spieler-HUD-Aktualisierung
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= -1 then
            local health = GetEntityHealth(playerPed)
            local displayHealth = (health - 100)
            if displayHealth < 0 then displayHealth = 0 end

            local armor = GetPedArmour(playerPed)
            
            SendNUIMessage({
                type = "update",
                health = math.floor(displayHealth),
                armor = armor,
                hunger = math.floor(hunger),
                thirst = math.floor(thirst),
                addiction = addiction,
                temperature = temperature
            })
        end
    end
end)

-- Thread für das Fahrzeug-HUD
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