
ESX = exports["es_extended"]:getSharedObject()

local isApplyingChains = false

ESX.RegisterUsableItem(Config.SnowChains.ItemName, function(cb)
    if isApplyingChains then return end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetClosestVehicle(coords)

    if DoesEntityExist(vehicle) and #(coords - GetEntityCoords(vehicle)) < 5.0 then
        isApplyingChains = true

        -- Animation
        ESX.Streaming.RequestAnimDict("anim@amb@garage@chassis_repair@")
        TaskPlayAnim(playerPed, "anim@amb@garage@chassis_repair@", "enter_right", 8.0, -8.0, -1, 49, 0, false, false, false)

        ESX.ShowNotification("Du beginnst damit, die Schneeketten anzubringen...")

        -- Wait for animation
        Citizen.Wait(15000) -- 15 Sekunden Animation

        ClearPedTasks(playerPed)

        local vehicleNetId = VehToNet(vehicle)
        TriggerServerEvent('snowchains:apply', vehicleNetId)
        isApplyingChains = false
    else
        ESX.ShowNotification("Du musst näher an einem Fahrzeug sein.")
    end
end)

RegisterNetEvent('snowchains:damageTires')
AddEventHandler('snowchains:damageTires', function(vehicleNetId)
    local vehicle = NetToVeh(vehicleNetId)
    if DoesEntityExist(vehicle) then
        -- Burst all tires
        for i = 0, 7 do
            if GetVehicleTyresCanBurst(vehicle) then
                SetVehicleTyreBurst(vehicle, i, true, 1000.0)
            end
        end
    end
end)

-- Interaktive Demontage
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if not vehicle or vehicle == 0 then
            vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(playerPed))
        end

        if DoesEntityExist(vehicle) and #(GetEntityCoords(playerPed) - GetEntityCoords(vehicle)) < 5.0 then
            local vehicleEntity = Entity(vehicle)
            if vehicleEntity.state.hasSnowChains then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~, um die Schneeketten zu entfernen.")
                if IsControlJustReleased(0, 38) then -- E
                    TriggerServerEvent('snowchains:remove', VehToNet(vehicle))
                end
            end
        end
    end
end)

ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)
