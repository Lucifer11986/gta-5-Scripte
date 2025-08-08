local ESX = exports['es_extended']:getSharedObject()

-- Initialize local variables.
-- These will be updated by the esx_status:onTick event.
local hunger = 100
local thirst = 100
local temperature = 15 -- Default value

function StartHudLogic()
    -- Event handler for ESX status updates. This is the standard way to get needs values.
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

    -- Thread for fetching temperature (still configurable)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10000) -- Update every 10 seconds

            if Config.WeatherResourceName and exports[Config.WeatherResourceName] and exports[Config.WeatherResourceName].GetTemperature then
                local tempValue = exports[Config.WeatherResourceName]:GetTemperature()
                if tempValue then
                    temperature = tempValue
                end
            end
        end
    end)

    -- Main HUD update thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500) -- NUI update interval

            local playerPed = PlayerPedId()
            local health = (GetEntityHealth(playerPed) - 100) / (GetEntityMaxHealth(playerPed) - 100) * 100
            local armor = GetPedArmour(playerPed)

            local addiction = 0
            if Config.AddictionResourceName and exports[Config.AddictionResourceName] and exports[Config.AddictionResourceName].GetAddictionLevel then
                addiction = exports[Config.AddictionResourceName]:GetAddictionLevel() or 0
            end

            SendNUIMessage({
                type = "update",
                health = math.floor(health),
                armor = armor,
                hunger = math.floor(hunger),
                thirst = math.floor(thirst),
                addiction = addiction,
                temperature = temperature
            })
        end
    end)
end

-- This initial thread waits until the Config is loaded before starting the main logic.
Citizen.CreateThread(function()
    while Config == nil do
        Citizen.Wait(500)
    end
    StartHudLogic()
end)
