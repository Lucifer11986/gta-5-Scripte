local activeParticles = {}
local currentSeason = "Winter"  -- Standardmäßig auf Winter setzen
local currentTemperature = 0
local isHeatwave = false
local snowActive = false
local waterLevel = 100 -- Simulierter Wasserstand
local ESX = nil
local maxHealth = 200 -- Maximale Gesundheit
local minHealth = 10  -- Min. Gesundheit (5% der maximalen Gesundheit)

-- **ESX Laden**
Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(500)
    end
end)

-- **Jede Minute Kleidung und Wasserstatus prüfen**
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Alle 60 Sekunden prüfen
        CheckPlayerClothingAndHydration()
    end
end)

-- **Kleidung & Dehydration prüfen**
function CheckPlayerClothingAndHydration()
    local playerPed = PlayerPedId()
    local playerHealth = GetEntityHealth(playerPed)
    local shirt = GetPedDrawableVariation(playerPed, 11) -- Oberteil
    local pants = GetPedDrawableVariation(playerPed, 4)  -- Hose

    -- Debugging: Kleidungswerte ausgeben
    print("[Kleidung Check] Shirt: " .. shirt .. ", Hose: " .. pants)

    -- Sicherstellen, dass currentTemperature eine Zahl ist
    currentTemperature = tonumber(currentTemperature) or 0

    -- **Winter-Kleidungskontrolle**
    if currentSeason == "Winter" and currentTemperature <= 0 then
        if IsWearingLightClothing(shirt, pants) then
            playerHealth = playerHealth - 3
            if playerHealth < minHealth then playerHealth = minHealth end
            SetEntityHealth(playerPed, playerHealth)
            ShowSeasonNotification("❄️ Du trägst zu leichte Kleidung im Winter! Gesundheit sinkt schneller...", 5)
        elseif IsWearingMediumClothing(shirt, pants) then
            playerHealth = playerHealth - 1
            if playerHealth < minHealth then playerHealth = minHealth end
            SetEntityHealth(playerPed, playerHealth)
            ShowSeasonNotification("❄️ Deine Kleidung ist nicht warm genug! Gesundheit sinkt langsam...", 5)
        end
    end

    -- **Sommer-Kleidung & Hitzewelle**
    if currentSeason == "Sommer" and currentTemperature >= 29 then
        if isHeatwave then
            playerHealth = playerHealth - 2
            if playerHealth < minHealth then playerHealth = minHealth end
            SetEntityHealth(playerPed, playerHealth)
            ShowSeasonNotification("🔥 Es ist extrem heiß! Suche Schatten oder trinke Wasser.", 5)
        elseif waterLevel <= 0 then
            playerHealth = playerHealth - 2
            if playerHealth < minHealth then playerHealth = minHealth end
            SetEntityHealth(playerPed, playerHealth)
            ShowSeasonNotification("💧 Dein Wasserstand ist auf 0! Gesundheit sinkt aufgrund Dehydration.", 5)
        end
    end
end

-- **Check-Funktionen für Kleidung**
function IsWearingLightClothing(shirt, pants)
    return (shirt >= 0 and shirt <= 5) or (pants >= 0 and pants <= 5)
end

function IsWearingMediumClothing(shirt, pants)
    return (shirt >= 6 and shirt <= 14) or (pants >= 6 and pants <= 9)
end

function IsWearingWarmClothing(shirt, pants)
    return (shirt >= 15) or (pants >= 10)
end

-- **Benachrichtigung für Jahreszeiten-Wechsel**
RegisterNetEvent("season:notifySeasonChange")
AddEventHandler("season:notifySeasonChange", function(seasonName, temperature)
    if not seasonName or seasonName == "" then seasonName = "Unbekannt" end
    if type(temperature) ~= "number" then
        temperature = tonumber(temperature) or 0  -- Stelle sicher, dass die Temperatur eine Zahl ist
    end

    currentSeason = seasonName  -- Setze die aktuelle Jahreszeit
    currentTemperature = temperature  -- Setze die aktuelle Temperatur zum Zeitpunkt des Wechsels

    local message = "🌍 Die Jahreszeit wechselt... Willkommen im " .. seasonName .. "! 🌡 Temperatur: " .. string.format("%.1f°C", currentTemperature)
    ShowSeasonNotification(message, 10)
end)

-- **Anzeige einer Nachricht**
function ShowSeasonNotification(text, duration)
    Citizen.CreateThread(function()
        local endTime = GetGameTimer() + (duration * 1000)
        while GetGameTimer() < endTime do
            Citizen.Wait(0)
            DrawTextOnScreen(text, 0.5, 0.1)
        end
    end)
end

-- **Zeigt Text auf dem Bildschirm**
function DrawTextOnScreen(text, x, y)
    SetTextFont(4)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end
