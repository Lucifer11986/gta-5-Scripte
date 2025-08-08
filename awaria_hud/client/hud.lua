local ESX = exports['es_extended']:getSharedObject()

-- Initialize local variables for needs
local hunger = 100.0
local thirst = 100.0
local energy = 100.0
local temperature = 15 -- Default value

-- Thread for decaying needs over time
Citizen.CreateThread(function()
    while true do
        -- Wait for 1 minute
        Citizen.Wait(60000)

        if Config.UseInternalNeeds then
            hunger = math.max(0, hunger - Config.HungerDecay)
            thirst = math.max(0, thirst - Config.ThirstDecay)
            energy = math.max(0, energy - Config.EnergyDecay)
        end
    end
end)

-- Thread for fetching temperature
Citizen.CreateThread(function()
    while true do
        -- Wait for 10 seconds as in the original script
        Citizen.Wait(10000)

        -- Use the configurable resource name for temperature
        if Config.WeatherResourceName and exports[Config.WeatherResourceName] and exports[Config.WeatherResourceName].GetTemperature then
            local tempValue = exports[Config.WeatherResourceName]:GetTemperature()
            if tempValue then
                temperature = tempValue
            end
        else
            -- You can uncomment the line below to debug if the temperature export is not found.
            -- print('Awaria HUD: Could not find export GetTemperature in resource ' .. (Config.WeatherResourceName or 'nil'))
        end
    end
end)

-- Main HUD update thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Update interval

        local playerPed = PlayerPedId()
        local health = (GetEntityHealth(playerPed) - 100) / (GetEntityMaxHealth(playerPed) - 100) * 100
        local armor = GetPedArmour(playerPed)

        local addiction = 0
        -- Use the configurable resource name for addiction
        if Config.AddictionResourceName and exports[Config.AddictionResourceName] and exports[Config.AddictionResourceName].GetAddictionLevel then
            addiction = exports[Config.AddictionResourceName]:GetAddictionLevel() or 0
        end

        local needsData = {
            hunger = math.floor(hunger),
            thirst = math.floor(thirst),
            energy = math.floor(energy)
        }

        -- This part handles if the user turns off the internal needs system.
        -- In that case, they would need to integrate their own script.
        if not Config.UseInternalNeeds then
            needsData.hunger = 100 -- Default display value
            needsData.thirst = 100 -- Default display value
            needsData.energy = 100 -- Default display value
        end

        SendNUIMessage({
            type = "update",
            health = math.floor(health),
            armor = armor,
            hunger = needsData.hunger,
            thirst = needsData.thirst,
            energy = needsData.energy,
            addiction = addiction,
            temperature = temperature
        })
    end
end)
