local isCleaning = false

RegisterNetEvent('graffiti:startCleanup')
AddEventHandler('graffiti:startCleanup', function()
    if isCleaning then return end
    isCleaning = true

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_MAID_CLEAN", 0, true)
    exports['progressBars']:startUI(5000, "Graffiti wird entfernt...")

    Citizen.Wait(5000)
    ClearPedTasksImmediately(playerPed)

    TriggerServerEvent('graffiti:removeGraffiti', coords)

    isCleaning = false
end)

RegisterCommand("clean", function()
    TriggerEvent('graffiti:startCleanup')
end, false)
