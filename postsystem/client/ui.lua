local UI = {}
local eventsRegistered = false -- Flag, um zu überprüfen, ob Events bereits registriert sind

-- Funktion zur Registrierung von Events
local function registerEvents()
    if eventsRegistered then return end -- Beende die Funktion, wenn Events bereits registriert sind

    -- 📩 **UI-Funktionen**
    function UI.SendMessage(action, data)
        SendNUIMessage({ action = action, data = data })
    end

    function UI.Open(stations, players, mail)
        if not stations then stations = {} end
        if not players then players = {} end
        if not mail then mail = {} end

        UI.SendMessage("openUI", {
            stations = stations,
            players = players,
            mail = mail
        })
        SetNuiFocus(true, true)
        print("📬 UI geöffnet")
    end

    function UI.Close()
        UI.SendMessage("closeUI", {})
        SetNuiFocus(false, false)
        print("📬 UI geschlossen")
    end

    -- UI schließen
    RegisterNUICallback("closeUI", function(_, cb)
        UI.Close()
        cb("ok")
    end)

    -- UI öffnen
    RegisterNetEvent("postsystem:openUI")
    AddEventHandler("postsystem:openUI", function(stations, players, mail)
        UI.Open(stations, players, mail)
    end)

    eventsRegistered = true -- Setze das Flag auf true, um zu signalisieren, dass Events registriert sind
end

-- Registriere Events beim Start
registerEvents()