ESX = exports["es_extended"]:getSharedObject()

-- Haupt-Schleife, die den Client zur Überprüfung auffordert Citizen.CreateThread(function() while true do -- Warte auf die Konfiguration, bevor die Schleife startet while Config == nil or Config.Survival == nil do Wait(1000) end

    Citizen.Wait(Config.Survival.CheckIntervalSeconds * 1000)
    
    local players = ESX.GetPlayers()
    for i = 1, #players do
        local xPlayer = ESX.GetPlayerFromId(players[i])
        if xPlayer then
            local currentTemperature = exports.weather_seasons:GetCurrentTemperature()
            -- Fordere den Client auf, Kleidung und Schutzstatus zu prüfen
            TriggerClientEvent('survival:checkClothingAndApplyEffects', xPlayer.source, currentTemperature)
        end
    end
end
end)

-- Event-Handler, der die Antwort vom Client empfängt und die Logik anwendet RegisterNetEvent('survival:applyEffects') AddEventHandler('survival:applyEffects', function(isWearingWarm, isSheltered, temperature) local src = source local xPlayer = ESX.GetPlayerFromId(src)

if not xPlayer then return end

-- Logik für Hitze
if temperature >= Config.Survival.HotTemperature then
    local thirst = xPlayer.get('thirst')
    if thirst ~= nil then
        local multiplier = 1.0
        if isWearingWarm then
            multiplier = Config.Survival.ClothingMultiplier
        end
        
        local newThirst = thirst - (Config.Survival.ThirstRate * multiplier)
        if newThirst < 0 then newThirst = 0 end
        xPlayer.set('thirst', newThirst)

        if newThirst <= 0 then
            TriggerClientEvent('survival:applyDamage', src, Config.Survival.HeatDamage)
            TriggerClientEvent('esx:showNotification', src, 'Du leidest an einem Hitzschlag! Finde schnell Wasser!')
        end
    else
        -- print("[Weather Seasons] WARNUNG: Spieler " .. xPlayer.identifier .. " hat keinen 'thirst'-Eintrag in seiner Status-Tabelle.")
    end

-- Logik für Kälte
elseif temperature <= Config.Survival.ColdTemperature then
    -- Wende nur Schaden an, wenn Spieler NICHT geschützt UND NICHT warm angezogen ist
    if not isSheltered and not isWearingWarm then
        TriggerClientEvent('survival:applyDamage', src, Config.Survival.FreezingDamage)
        TriggerClientEvent('esx:showNotification', src, 'Dir ist eiskalt! Zieh dir etwas Warmes an oder suche Schutz!')
        TriggerClientEvent('survival:setFreezingEffect', src, true)
    else
        -- Deaktiviere den Effekt, wenn Spieler geschützt ist oder warme Kleidung trägt
        TriggerClientEvent('survival:setFreezingEffect', src, false)
    end

-- Weder zu heiß noch zu kalt
else
    TriggerClientEvent('survival:setFreezingEffect', src, false)
end
end)