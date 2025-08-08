ESX = exports["es_extended"]:getSharedObject()

-- Diese Funktion überprüft die Kleidung des Spielers und gibt einen Multiplikator zurück.
function getClothingMultiplier()
    local playerPed = PlayerPedId()
    local multiplier = 1.0 -- Standard-Multiplikator

    -- Überprüfe die Jacke (Component ID 11)
    local jacketId = GetPedDrawableVariation(playerPed, 11)
    if Config.WarmClothing.jackets[jacketId] then
        multiplier = Config.Survival.ClothingMultiplier
        return multiplier -- Wenn eine warme Jacke getragen wird, ist der höchste Multiplikator erreicht
    end

    -- Hier könnten weitere Checks für andere Kleidungsstücke (Hosen, etc.) hinzugefügt werden

    return multiplier
end

-- Registriere einen Server-Callback, damit der Server den Multiplikator abfragen kann
ESX.RegisterServerCallback('survival:getClothingMultiplier', function(source, cb)
    local multiplier = getClothingMultiplier()
    cb(multiplier)
end)
