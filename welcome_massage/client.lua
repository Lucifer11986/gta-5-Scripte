Citizen.CreateThread(function()
    -- 🕒 Warten, bis die Spielsitzung gestartet ist
    while not NetworkIsSessionStarted() do
        Citizen.Wait(500)
    end

    -- 🏷 Spieler-Name abrufen
    local playerName = GetPlayerName(PlayerId())

    -- 📂 Willkommensnachricht aus der Konfiguration abrufen
    local welcomeMessage = string.format(Config.WelcomeMessage, playerName)

    -- 📢 Nachricht anzeigen
    ShowSeasonNotification(welcomeMessage, Config.MessageDuration)
end)

-- **📢 Nachricht auf dem Bildschirm anzeigen**
function ShowSeasonNotification(text, duration)
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + (duration * 1000)
        while GetGameTimer() < endTime do
            Citizen.Wait(0)
            DrawTextOnScreen(text, 0.5, 0.2)
        end
    end)
end

-- **📝 Text auf dem Bildschirm darstellen**
function DrawTextOnScreen(text, x, y)
    SetTextFont(4)
    SetTextScale(0.6, 0.6)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)

    -- 📜 Text in mehrere Zeilen aufteilen
    local lines = SplitTextToLines(text, 80)
    local lineHeight = 0.05

    for i, line in ipairs(lines) do
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(line)
        EndTextCommandDisplayText(x, y + (i - 1) * lineHeight)
    end
end

-- **🔍 Funktion zum Aufteilen langer Texte in mehrere Zeilen**
function SplitTextToLines(text, maxLength)
    local lines, currentLine = {}, ""

    for word in string.gmatch(text, "%S+") do
        if #currentLine + #word + 1 > maxLength then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = (currentLine == "" and word or currentLine .. " " .. word)
        end
    end

    table.insert(lines, currentLine)
    return lines
end
