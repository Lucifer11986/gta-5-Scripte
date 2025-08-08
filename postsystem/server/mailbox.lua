-- server/mailbox.lua

-- Briefkasten platzieren
RegisterServerEvent("postsystem:placeMailbox")
AddEventHandler("postsystem:placeMailbox", function(coords, heading)
    local src = source
    local player = GetPlayerIdentifiers(src)[1]

    MySQL.Async.execute("INSERT INTO mailboxes (owner, x, y, z, heading) VALUES (@owner, @x, @y, @z, @heading)", {
        ["@owner"] = player,
        ["@x"] = coords.x,
        ["@y"] = coords.y,
        ["@z"] = coords.z,
        ["@heading"] = heading
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent("postsystem:notify", src, "Briefkasten erfolgreich platziert!")
        end
    end)
end)

-- Briefkasten öffnen
RegisterServerEvent("postsystem:fetchMailbox")
AddEventHandler("postsystem:fetchMailbox", function(playerId)
    local src = source

    MySQL.Async.fetchAll("SELECT * FROM mail_queue WHERE receiver = @receiver AND delivered = false", {
        ["@receiver"] = playerId
    }, function(result)
        if result then
            TriggerClientEvent("postsystem:openMailboxUI", src, result)
        end
    end)
end)