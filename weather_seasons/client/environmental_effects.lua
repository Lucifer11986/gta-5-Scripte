local currentSeason = nil
local currentTemperature = 20
local isLeafEffectActive = false
local leafEffectThread = nil

-- Event-Handler, um die aktuelle Jahreszeit und Temperatur zu speichern
AddEventHandler('season:updateSeason', function(seasonName, temperature)
    currentSeason = seasonName
    currentTemperature = temperature
end)

-- Funktion für den Laub-Effekt
function startLeafEffect()
    if isLeafEffectActive then return end
    isLeafEffectActive = true

    leafEffectThread = Citizen.CreateThread(function()
        local particleDict = "ent_amb"
        local particleName = "ent_amb_leaf_fall_apart"
        RequestNamedPtfxAsset(particleDict)
        while not HasNamedPtfxAssetLoaded(particleDict) do
            Citizen.Wait(50)
        end

        while currentSeason == "Herbst" do
            Citizen.Wait(math.random(5000, 10000)) -- Alle 5-10 Sekunden
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) == false then -- Nur wenn Spieler zu Fuß ist
                local coords = GetEntityCoords(playerPed)
                UseParticleFxAtCoord(particleName, coords.x, coords.y, coords.z + 5.0, 0.0, 0.0, 0.0, 3.0, false, false, false, false)
            end
        end
        isLeafEffectActive = false
    end)
end

-- Funktion für den Glatteis-Effekt
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Jede Sekunde prüfen
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if currentSeason == "Winter" and currentTemperature < 0 then
                SetVehicleReduceGrip(vehicle, true)
            else
                SetVehicleReduceGrip(vehicle, false)
            end
        end
    end
end)

-- Haupt-Thread, der die Effekte basierend auf der Jahreszeit steuert
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Alle 5 Sekunden prüfen, ob der Effekt gestartet werden muss
        if currentSeason == "Herbst" then
            startLeafEffect()
        end
    end
end)
