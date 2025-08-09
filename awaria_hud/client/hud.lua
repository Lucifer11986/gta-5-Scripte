local ESX = exports['es_extended']:getSharedObject()

-- Variablen, die von Events aktualisiert werden
local hunger = 100
local thirst = 100

-- Event-Handler für ESX-Status (Hunger und Durst)
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

-- Neuer Thread für das Fahrzeug-HUD
Citizen.CreateThread(function()
    local inVehicle = false
    local wasInVehicle = false

    while true do
        Citizen.Wait(250) -- Check for vehicle status 4 times a second

        local playerPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)
        inVehicle = (currentVehicle ~= 0)

        if inVehicle ~= wasInVehicle then
            SendNUIMessage({ type = "showVehicle", show = inVehicle })
            wasInVehicle = inVehicle
        end

        if inVehicle then
            local speed = GetEntitySpeed(currentVehicle) * 3.6 -- Speed in km/h
            local fuel = GetVehicleFuelLevel(currentVehicle)
            local engineHealth = GetVehicleEngineHealth(currentVehicle) / 10 -- Convert from 0-1000 to 0-100 scale

            SendNUIMessage({
                type = "updateVehicle",
                speed = math.floor(speed),
                fuel = math.floor(fuel),
                engineHealth = math.floor(engineHealth)
            })
        end
    end
end)

-- Haupt-Thread für die HUD-Aktualisierung
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Aktualisierungsintervall

        local playerPed = PlayerPedId()
        if playerPed and playerPed ~= -1 then
            local health = GetEntityHealth(playerPed)
            -- Gesundheit in GTA ist 100 (fast tot) bis 200 (voll). Wir mappen das auf 0-100.
            local displayHealth = (health - 100)
            if displayHealth < 0 then displayHealth = 0 end

            local armor = GetPedArmour(playerPed)

            SendNUIMessage({
                type = "update",
                health = math.floor(displayHealth),
                armor = armor,
                hunger = math.floor(hunger),
                thirst = math.floor(thirst)
            })
        end
    end
end)
