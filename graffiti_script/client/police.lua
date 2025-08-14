-- This script handles the client-side logic for the police alert system.
RegisterNetEvent('graffiti:policeAlert')
AddEventHandler('graffiti:policeAlert', function(coords)
    -- Create a blip on the map for the police
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, Config.PoliceSystem.BlipSprite)
    SetBlipColour(blip, Config.PoliceSystem.BlipColour)
    SetBlipScale(blip, Config.PoliceSystem.BlipScale)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Illegales Graffiti")
    EndTextCommandSetBlipName(blip)

    -- Create a thread to remove the blip after the configured duration
    Citizen.CreateThread(function()
        Wait(Config.PoliceSystem.BlipDuration * 1000)
        RemoveBlip(blip)
    end)
end)
