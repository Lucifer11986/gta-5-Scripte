local Framework = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while Framework == nil do
        if GetResourceState('es_extended') == 'started' then
            Framework = exports['es_extended']:getSharedObject()
        elseif GetResourceState('qb-core') == 'started' then
            Framework = exports['qb-core']:GetCoreObject()
        elseif GetResourceState('esy') == 'started' then
            Framework = exports['esy']:getSharedObject()
        end
        Citizen.Wait(500)
    end

    if Framework then
        if Framework.PlayerLoaded then
            PlayerData = Framework.GetPlayerData()
        elseif Framework.Functions and Framework.Functions.GetPlayerData then
            PlayerData = Framework.Functions.GetPlayerData()
        end
    end
end)

-- Sommer-Aktivitäten (z.B. JetSki-Rennen)
RegisterNetEvent("sommer:startJetSkiRace")
AddEventHandler("sommer:startJetSkiRace", function()
    local playerPed = PlayerPedId()
    local jetSkiModel = GetHashKey("seashark")
    RequestModel(jetSkiModel)

    while not HasModelLoaded(jetSkiModel) do
        Citizen.Wait(100)
    end

    local spawnCoords = vector3(-1600.0, -1200.0, 0.0) -- Beispiel-Spawnpunkt
    local vehicle = CreateVehicle(jetSkiModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Viel Spaß beim JetSki-Rennen!" } })
end)

-- Wasser-Battle (Minispiel)
local waterBattleActive = false

RegisterNetEvent("sommer:startWaterBattle")
AddEventHandler("sommer:startWaterBattle", function()
    if not waterBattleActive then
        waterBattleActive = true
        TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Wasser-Battle startet! Schnapp dir deine Wasserpistole!" } })
        Citizen.SetTimeout(60000, function() -- Wasser-Battle dauert 1 Minute
            waterBattleActive = false
            TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Das Wasser-Battle ist vorbei!" } })
        end)
    else
        TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Das Wasser-Battle läuft bereits!" } })
    end
end)

RegisterNetEvent("sommer:shootWater")
AddEventHandler("sommer:shootWater", function(targetPed)
    if waterBattleActive then
        local playerPed = PlayerPedId()
        local targetPed = GetPlayerPed(-1) -- Hier müsste der tatsächliche Zielspieler übergeben werden
        -- Hier könntest du eine Animation oder Effekt für den Wasserschuss hinzufügen
        TriggerServerEvent("sommer:applyWaterDamage", targetPed) -- Server-sseitige Berechnung des Wasserschaden
    end
end)

-- Ernte-Wettbewerb
local harvestCompetitionActive = false

RegisterNetEvent("sommer:startHarvestCompetition")
AddEventHandler("sommer:startHarvestCompetition", function()
    if not harvestCompetitionActive then
        harvestCompetitionActive = true
        TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Der Ernte-Wettbewerb hat begonnen! Wer wird der Schnellste sein?" } })
        Citizen.SetTimeout(60000, function() -- Wettbewerb dauert 1 Minute
            harvestCompetitionActive = false
            TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Der Ernte-Wettbewerb ist vorbei!" } })
        end)
    else
        TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Der Ernte-Wettbewerb läuft bereits!" } })
    end
end)

RegisterNetEvent("sommer:harvestCrop")
AddEventHandler("sommer:harvestCrop", function()
    if harvestCompetitionActive then
        -- Ernte-Logik, z.B. das Ernten von Pflanzen
        TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Du hast eine Pflanze geerntet!" } })
    else
        TriggerEvent('chat:addMessage', { args = { "[SOMMER]", "Der Wettbewerb ist nicht aktiv!" } })
    end
end)

-- Sommerbelohnung sammeln
RegisterNetEvent("sommer:collectReward")
AddEventHandler("sommer:collectReward", function()
    TriggerServerEvent("sommer:giveReward")
end)