local currentSeason = nil
local activeParticles = {}
local snowActive = false -- Flag, um den Schneestatus zu verwalten
local lastUpdate = GetGameTimer()
local transitionTime = 3000  -- Übergangszeit in Millisekunden (3 Sekunden)

-- Hilfsfunktion: Partikel starten
local function startParticleEffect(effectName, coords, loop)
    UseParticleFxAssetNextCall('core')
    local particle = StartParticleFxLoopedAtCoord(effectName, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, loop)
    return particle
end

-- Hilfsfunktion: Partikeleffekte beenden
local function stopParticleEffects()
    for _, particle in ipairs(activeParticles) do
        StopParticleFxLooped(particle, false)
    end
    activeParticles = {}
end

-- Schnee auf den Boden legen
local function setSnowOnGround(enable)
    if enable and not snowActive then
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
        snowActive = true
    elseif not enable and snowActive then
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
        snowActive = false
    end
end

-- Effekte für Frühling starten
local function springEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_amb_pollen_fall", coords, true))
end

-- Effekte für Sommer starten
local function summerEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_amb_sun_light", coords, true))
end

-- Effekte für Herbst starten
local function autumnEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_amb_leaf_blower", coords, true))
end

-- Effekte für Winter starten
local function winterEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_snow_wind_falling", coords, true))
end

-- Übergang zwischen den Jahreszeiten
local function transitionToSeason(newSeason)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    stopParticleEffects()
    setSnowOnGround(false)

    Citizen.Wait(transitionTime / 2)

    if newSeason == "Frühling" then
        springEffects(coords)
    elseif newSeason == "Sommer" then
        summerEffects(coords)
    elseif newSeason == "Herbst" then
        autumnEffects(coords)
    elseif newSeason == "Winter" then
        winterEffects(coords)
    end

    if newSeason == 'Winter' then
        setSnowOnGround(true)
    end
end

-- Event: Jahreszeit aktualisieren (KORRIGIERT)
RegisterNetEvent('season:updateSeason', function(seasonName, temperature)
    if not seasonName then
        print("[Weather Seasons] Ungültiges season:updateSeason Event empfangen.")
        return
    end
    currentSeason = seasonName
    transitionToSeason(seasonName)
end)

-- Event: Temperatur aktualisieren
RegisterNetEvent('weather_seasons:updateTemperature', function(temperature)
    -- Hier könnten in Zukunft temperaturabhängige Effekte auf dem Client gehandhabt werden
end)

-- Initiale Synchronisation mit dem Server
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('weather_seasons:requestSync')
    end
end)

-- Beim Verlassen des Spiels alle Effekte stoppen
AddEventHandler('playerDropped', function()
    stopParticleEffects()
end)

-- Diese Funktion sorgt für die wiederkehrenden Partikeleffekte
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000) -- Prüfe alle 30 Sekunden

        if currentSeason == 'Frühling' then
            local playerPed = PlayerPedId()
            if IsEntityOnScreen(playerPed) then
                springEffects(GetEntityCoords(playerPed))
            end
        elseif currentSeason == 'Herbst' then
            local playerPed = PlayerPedId()
            if IsEntityOnScreen(playerPed) then
                autumnEffects(GetEntityCoords(playerPed))
            end
        end
    end
end)
