local isMenuOpen = false
local selectedIndex = 1 -- Aktuell ausgewähltes Stockwerk im Menü
local currentElevatorIndex = nil -- Aktueller Fahrstuhl
local isNearElevator = false -- Status, ob der Spieler in der Nähe eines Fahrstuhls ist

-- Dynamisches Laden der Stockwerksdaten aus config.lua
local elevatorConfig = Config.Elevator

-- Funktion zur Überprüfung der Nähe zum Fahrstuhl
local function isPlayerNearElevator()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for elevatorIndex, elevator in ipairs(elevatorConfig) do
        for _, floor in pairs(elevator.floors) do
            if Vdist(playerCoords, floor.x, floor.y, floor.z) < 1.0 then -- Distanz angepasst
                currentElevatorIndex = elevatorIndex
                return true
            end
        end
    end
    currentElevatorIndex = nil
    return false
end

-- Erweiterte Sicherheitsprüfung für Zielkoordinaten
local function isFloorAccessible(floor)
    local playerPed = PlayerPedId()
    local testCoords = vector3(floor.x, floor.y, floor.z + 1.0) -- Erhöhe Z leicht, um sicherzustellen, dass der Spieler nicht in Objekten steckt
    local isClear = not IsPointObscuredByAMissionEntity(testCoords.x, testCoords.y, testCoords.z)

    -- Zusätzliche Prüfung auf mögliche Hindernisse
    local groundZ, isGroundValid = GetGroundZFor_3dCoord(floor.x, floor.y, floor.z, false)
    return isClear and isGroundValid
end

-- Funktion zum Abspielen von Animationen
local function playElevatorAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("move_m@business@a") -- Neue Animation passend zur Situation
    while not HasAnimDictLoaded("move_m@business@a") do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, "move_m@business@a", "walk", 8.0, -8.0, 2000, 1, 0, false, false, false)
    Citizen.Wait(2000) -- Simulierte Fahrzeit
    ClearPedTasks(playerPed)
end

-- Funktion zur Anzeige einer Markierung am Fahrstuhl
local function drawElevatorMarker()
    if currentElevatorIndex then
        local elevator = elevatorConfig[currentElevatorIndex]
        for _, floor in pairs(elevator.floors) do
            DrawMarker(
                25, -- Typ 25 ist ein grüner Kreis
                floor.x, floor.y, floor.z - 0.95, -- Z leicht abgesenkt für den Kreis
                0.0, 0.0, 0.0, -- Richtung
                0.0, 0.0, 0.0, -- Drehung
                0.8, 0.8, 0.8, -- Größe des Kreises
                0, 255, 0, 150, -- Farbe (Grün, 150 Transparenz)
                false, -- Boden prüfen
                true, -- Markierung kann auf entferntere Objekte gezeichnet werden
                2, -- Typ der Markierung
                nil, nil, false -- Keine Texturen, keine Rotation
            )
        end
    end
end

-- Hauptthread für Menü und Fahrstuhlinteraktionen
Citizen.CreateThread(function()
    while true do
        local wasNearElevator = isNearElevator
        isNearElevator = isPlayerNearElevator()

        if isNearElevator and not isMenuOpen then
            if not wasNearElevator then
                showInfobar('Drücke ~g~E~s~, um den Fahrstuhl zu nutzen')
            end
            if IsControlJustReleased(0, 38) then -- Wenn "E" gedrückt wird
                openElevatorMenu() -- Menü öffnen
            end
        elseif not isNearElevator and wasNearElevator then
            ClearHelp(true) -- Entferne die Infobar, wenn der Spieler sich entfernt
        end

        drawElevatorMarker() -- Grüne Kreismarkierung anzeigen

        Citizen.Wait(1)
    end
end)

-- Funktion zum Öffnen des Menüs
function openElevatorMenu()
    if not currentElevatorIndex then return end
    isMenuOpen = true
    local elevatorFloors = elevatorConfig[currentElevatorIndex].floors

    Citizen.CreateThread(function()
        while isMenuOpen do
            -- Menüsteuerung (Hoch und Runter mit Pfeiltasten)
            if IsControlJustReleased(0, 172) then -- Pfeil nach oben
                selectedIndex = selectedIndex - 1
                if selectedIndex < 1 then
                    selectedIndex = #elevatorFloors -- Gehe zum letzten Element
                end
            elseif IsControlJustReleased(0, 173) then -- Pfeil nach unten
                selectedIndex = selectedIndex + 1
                if selectedIndex > #elevatorFloors then
                    selectedIndex = 1 -- Gehe zum ersten Element
                end
            elseif IsControlJustReleased(0, 191) then -- Enter-Taste (Auswahl)
                local selectedFloor = elevatorFloors[selectedIndex]
                if isFloorAccessible(selectedFloor) then
                    playElevatorAnimation() -- Animation abspielen
                    SetEntityCoords(PlayerPedId(), selectedFloor.x, selectedFloor.y, selectedFloor.z)
                else
                    showInfobar('Der gewählte Ort ist blockiert!')
                end
                isMenuOpen = false -- Schließe Menü nach Auswahl
            elseif IsControlJustReleased(0, 202) then -- Rücktaste (Menü schließen)
                isMenuOpen = false
            end

            -- Menü anzeigen
            drawMenu(elevatorFloors)

            Citizen.Wait(1)
        end
    end)
end

-- Funktion zur Darstellung des Menüs auf dem Bildschirm
local function drawMenuHeader()
    SetTextFont(4) -- Schriftart ändern für modernere Darstellung
    SetTextProportional(1)
    SetTextScale(0.8, 0.8) -- Größe leicht erhöhen
    SetTextColour(0, 200, 255, 255) -- Farbe ändern zu Cyan
    SetTextEntry("STRING")
    AddTextComponentString("~b~Fahrstuhlmenü~s~") -- Text mit Farbe formatieren
    DrawText(0.5, 0.2) -- Position auf dem Bildschirm (etwas höher gesetzt)
end

local function drawMenuOptions(floors)
    for i, floor in ipairs(floors) do
        local text = floor.label
        local yPos = 0.3 + (i * 0.04) -- Abstand zwischen Einträgen erhöhen

        if i == selectedIndex then
            -- Hintergrund für das ausgewählte Stockwerk zeichnen
            DrawRect(0.5, yPos + 0.012, 0.3, 0.04, 50, 50, 50, 200) -- Grauer Hintergrund mit Transparenz
            text = "~g~> " .. text .. " <~s~" -- Hervorheben des ausgewählten Elements
        end

        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.5, 0.5)
        SetTextColour(255, 255, 255, 255) -- Weißer Text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(0.5, yPos) -- Positioniere die Liste der Stockwerke
    end
end

function drawMenu(floors)
    drawMenuHeader()
    drawMenuOptions(floors)
end

-- Funktion zur Anzeige von Info-Text (Infobar)
function showInfobar(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end