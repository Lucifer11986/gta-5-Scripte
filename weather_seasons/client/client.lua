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
    table.insert(activeParticles, startParticleEffect("ent_amb_pollen_fall", coords, true))  -- Schwebende Pollen
    TriggerEvent('weather_seasons:startRain')  -- Regen für den Frühling
end

-- Effekte für Sommer starten
local function summerEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_amb_sun_light", coords, true))  -- Sonnenstrahlen
    TriggerEvent('weather_seasons:startHeatWave')  -- Hitze
end

-- Effekte für Herbst starten
local function autumnEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_amb_leaf_blower", coords, true))  -- Blätter wehen
    TriggerEvent('weather_seasons:startStorm')  -- Herbststurm
end

-- Effekte für Winter starten
local function winterEffects(coords)
    table.insert(activeParticles, startParticleEffect("ent_snow_wind_falling", coords, true))  -- Schneefall
    TriggerEvent('weather_seasons:startSnowStorm')  -- Schneesturm
end

-- Übergang zwischen den Jahreszeiten
local function transitionToSeason(newSeason)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Partikeleffekte und Schnee sofort stoppen
    stopParticleEffects()
    setSnowOnGround(false)

    -- Den Übergang sanft starten
    Citizen.Wait(transitionTime / 2)  -- Übergang halbieren, bevor Effekte starten

    -- Effekte basierend auf der neuen Jahreszeit starten
    if newSeason == "Frühling" then
        springEffects(coords)
    elseif newSeason == "Sommer" then
        summerEffects(coords)
    elseif newSeason == "Herbst" then
        autumnEffects(coords)
    elseif newSeason == "Winter" then
        winterEffects(coords)
    end

    -- Schnee-Effekte verwalten
    if newSeason == 'Winter' then
        setSnowOnGround(true) -- Schnee auf den Boden legen
    end
end

-- Effekte für jede Jahreszeit starten
local function startSeasonEffects(season)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    stopParticleEffects() -- Vorherige Effekte stoppen

    if season == "Frühling" then
        springEffects(coords)
    elseif season == "Sommer" then
        summerEffects(coords)
    elseif season == "Herbst" then
        autumnEffects(coords)
    elseif season == "Winter" then
        winterEffects(coords)
    end
end

-- Event: Jahreszeit aktualisieren
RegisterNetEvent('weather_seasons:updateSeason', function(season, effects)
    if not effects then
        print("^1[ERROR]^0 'effects' ist nil! Überprüfe die Server-Konfiguration.")
        return
    end

    currentSeason = season

    -- Wetter aktualisieren (sanft)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeOvertimePersist(effects.weather, transitionTime / 1000)
    SetWeatherTypeNow(effects.weather)
    SetWeatherTypeNowPersist(effects.weather)

    -- Partikeleffekte basierend auf der Jahreszeit starten
    transitionToSeason(season)

    -- Schnee-Effekte verwalten
    if season == 'Winter' then
        setSnowOnGround(true) -- Schnee auf den Boden legen
    else
        setSnowOnGround(false) -- Schnee entfernen
    end
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

-- Diese Funktion regelmäßig zur Überprüfung der Wetterereignisse aufrufen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Überprüfe jede Sekunde

        -- Überprüfe, ob Frühling oder Herbst ist und starte das passende Wetter
        if currentSeason == 'Frühling' then
            -- Startet die Frühlingseffekte (Blumen, Regen, etc.)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            springEffects(coords)
        elseif currentSeason == 'Herbst' then
            -- Startet die Herbst-Effekte (Fallende Blätter, Sturm, etc.)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            autumnEffects(coords)
        end
    end
end)
