local waterBattleStats = {}

-- Funktion für das Speichern der Treffer im Wasser-Battle
RegisterServerEvent("register_water_battle_hit")
AddEventHandler("register_water_battle_hit", function(playerId)
    if not waterBattleStats[playerId] then
        waterBattleStats[playerId] = 0
    end
    waterBattleStats[playerId] = waterBattleStats[playerId] + 1

    -- Belohnung nach einer bestimmten Anzahl an Treffern
    if waterBattleStats[playerId] >= 10 then
        TriggerEvent("give_water_battle_reward", playerId)
    end
end)

-- Funktion zur Verteilung der Belohnung (z.B. Sommerkleidung, Getränke)
RegisterServerEvent("give_water_battle_reward")
AddEventHandler("give_water_battle_reward", function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    -- Sommerkleidung hinzufügen (z.B. Flip-Flops)
    xPlayer.addInventoryItem("flip_flops", 1)

    -- Kokoswasser mit Ausdauer-Boost
    xPlayer.addInventoryItem("coconut_water", 1)

    -- Wasserpistole als Item
    xPlayer.addInventoryItem("water_pistol", 1)

    TriggerClientEvent("notification", playerId, "Du hast eine Belohnung für deine Treffer erhalten!")
end)
