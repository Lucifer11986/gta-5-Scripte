ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback("hud:getUserData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({ health = 100, armor = 0, hunger = 100, thirst = 100, energy = 100 })
        return
    end

    local identifier = xPlayer.identifier
    local data = { health = 100, armor = 0, hunger = 100, thirst = 100, energy = 100 }

    -- Werte aus der Datenbank abrufen
    local result = MySQL.query.await("SELECT health, armor, hunger, thirst, energy FROM users WHERE identifier = ?", {identifier})
    
    if result and result[1] then
        data.health = result[1].health or 100
        data.armor = result[1].armor or 0
        data.hunger = result[1].hunger or 100
        data.thirst = result[1].thirst or 100
        data.energy = result[1].energy or 100
    end

    cb(data)
end)
