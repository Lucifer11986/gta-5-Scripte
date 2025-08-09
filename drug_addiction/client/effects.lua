local addictionLevel = 0

-- 📌 Funktion: Droge konsumieren (Effekte aktivieren)
RegisterNetEvent('drug_addiction:applyEffects')
AddEventHandler('drug_addiction:applyEffects', function(drug)
    local drugData = Config.Drugs[drug]
    if not drugData then return end

    local playerPed = PlayerPedId()

    -- Bildschirm-Effekte
    StartScreenEffect("DrugsMichaelAliensFight", 3.0, false) -- Verzerrter Bildschirm
    ShakeGameplayCam("DRUNK_SHAKE", 0.3) -- Wackelkamera

    -- Bewegungs-Effekte
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.2) -- Schneller rennen
    SetTimecycleModifier("drug_drive_blend01") -- Farbveränderung

    -- Zusätzliche Effekte je nach Droge
    if drugData.effect == "hallucinate" then
        -- Halluzinationen: Bunte Lichter
        StartScreenEffect("PlayerTransitionOut", 3.0, false)
    elseif drugData.effect == "speed" then
        -- Speed: Beschleunigungseffekte
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.5)
    end

    -- Dauer der Effekte (10-15 Sekunden)
    Wait(math.random(10000, 15000))

    -- Effekte deaktivieren
    StopScreenEffect("DrugsMichaelAliensFight")
    StopGameplayCamShaking(true)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    ClearTimecycleModifier()

    -- Falls Halluzinationseffekte angewendet wurden, diese ebenfalls stoppen
    if drugData.effect == "hallucinate" then
        StopScreenEffect("PlayerTransitionOut")
    end
end)

-- 📌 Funktion: Entzugserscheinungen
RegisterNetEvent('drug_addiction:applyWithdrawalEffects')
AddEventHandler('drug_addiction:applyWithdrawalEffects', function()
    local playerPed = PlayerPedId()

    -- Verschwommenes Sehen
    if Config.WithdrawalEffects.blur then
        StartScreenEffect("DeathFailMPDark", 3.0, false)
    end

    -- Wackelkamera
    if Config.WithdrawalEffects.shaking then
        ShakeGameplayCam("DRUNK_SHAKE", 0.5)
    end

    -- Langsamere Bewegung
    if Config.WithdrawalEffects.movementSlow then
        SetPedMoveRateOverride(playerPed, 0.5)
        SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
    end

    -- HP-Verlust
    if Config.WithdrawalEffects.healthLoss then
        local health = GetEntityHealth(playerPed)
        if health > 100 then
            SetEntityHealth(playerPed, health - 10)
        end
    end

    -- Dauer der Entzugserscheinungen (10-20 Sekunden)
    Wait(math.random(10000, 20000))

    -- Effekte deaktivieren
    StopScreenEffect("DeathFailMPDark")
    StopGameplayCamShaking(true)
    SetPedMoveRateOverride(playerPed, 1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end)

-- 📌 Funktion: Anwendung der Drogeneffekte
RegisterNetEvent('drug_system:applyDrugEffects')
AddEventHandler('drug_system:applyDrugEffects', function(drug)
    addictionLevel = addictionLevel + 10
    TriggerServerEvent('drug_system:updateAddiction', addictionLevel)

    -- Effekte für die verschiedenen Drogen
    if drug == "cocaine" then
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.2)
    elseif drug == "lsd" then
        SetTimecycleModifier("DRUG_2_drive")
        StartScreenEffect("DrugsMichaelAliensFight", 0, true)
    elseif drug == "meth" then
        SetTimecycleModifier("DRUG_gas_huffin")
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.5)
    elseif drug == "ecstasy" then
        SetTimecycleModifier("spectator5")
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.1)
        ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 0.1)
    elseif drug == "heroin" then
        SetTimecycleModifier("DRUG_2_drive")
        SetRunSprintMultiplierForPlayer(PlayerId(), 0.8)
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 10)
    elseif drug == "mushrooms" then
        SetTimecycleModifier("CAMERA_SHAKE_DARK")
        SetRunSprintMultiplierForPlayer(PlayerId(), 0.7)
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 10)
    end

    Citizen.Wait(60000) -- Effekte bleiben für 1 Minute aktiv
    ClearTimecycleModifier()
    StopScreenEffect("DrugsMichaelAliensFight")
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end)
