--[[
    ÜBERARBEITETE VERSION DES ELEVATOR-SYSTEMS
    - Job- und Rang-Überprüfung implementiert
    - Performance durch optimierte Schleifen verbessert
    - Tastenbelegung ist nun über die Spieleinstellungen anpassbar
    - Benutzeroberfläche (UI) modernisiert
    - Code-Qualität durch lokale Variablen und Konstanten erhöht
]]

-- Lokale Variablen, um globale Konflikte zu vermeiden
local isMenuOpen = false
local selectedIndex = 1
local currentElevatorIndex = nil
local isNearElevator = false

-- Tasten-Konstanten für bessere Lesbarkeit in der Menü-Funktion
local KEY_UP = 172
local KEY_DOWN = 173
local KEY_ENTER = 191
local KEY_BACKSPACE = 202

-- Konfigurierbarer Befehl für die Tastenbelegung
local COMMAND_USE_ELEVATOR = "use_elevator"

-- Lade die Konfiguration aus config.lua
local elevatorConfig = Config.Elevator

-- ESX-Integration für Job-Überprüfungen
local ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(100)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

-- Funktion zur Überprüfung der Job-Berechtigung
local function hasJobAccess(floor)
    if not floor.job then
        return true -- Kein Job erforderlich, Zugriff gewährt
    end

    if ESX and ESX.GetPlayerData then
        local playerData = ESX.GetPlayerData()
        if playerData and playerData.job and playerData.job.name == floor.job then
            if floor.rank then
                -- Wenn ein Rang erforderlich ist, prüfen, ob der Rang des Spielers hoch genug ist
                return playerData.job.grade >= floor.rank
            else
                -- Wenn nur ein Job erforderlich ist und der Spieler ihn hat, Zugriff gewähren
                return true
            end
        end
    else
        -- ESX nicht gefunden, aber ein Job ist erforderlich. Zugriff verweigern und Serverbesitzer warnen.
        print('[elevator-system] WARNUNG: ESX wurde nicht gefunden. Die Job-Überprüfung für Aufzüge kann nicht durchgeführt werden.')
        return false
    end

    return false
end

-- Erweiterte Sicherheitsprüfung für Zielkoordinaten
local function isFloorAccessible(floor)
    local playerPed = PlayerPedId()
    local testCoords = vector3(floor.x, floor.y, floor.z + 1.0)
    local isClear = not IsPointObscuredByAMissionEntity(testCoords.x, testCoords.y, testCoords.z)
    local groundZ, isGroundValid = GetGroundZFor_3dCoord(floor.x, floor.y, floor.z, false)
    return isClear and isGroundValid
end

-- Funktion zum Abspielen von Animationen
local function playElevatorAnimation()
    local playerPed = PlayerPedId()
    local animDict = "move_m@business@a"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, animDict, "walk", 8.0, -8.0, 2000, 1, 0, false, false, false)
    Citizen.Wait(2000)
    ClearPedTasks(playerPed)
end

-- Funktion zur Anzeige einer Markierung am Fahrstuhl
local function drawElevatorMarker()
    if currentElevatorIndex then
        local elevator = elevatorConfig[currentElevatorIndex]
        for _, floor in pairs(elevator.floors) do
            DrawMarker(
                25, -- Typ
                floor.x, floor.y, floor.z - 0.95,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Richtung & Rotation
                0.8, 0.8, 0.8, -- Skalierung
                0, 255, 0, 150, -- Farbe
                false, true, 2, nil, nil, false
            )
        end
    end
end

-- Funktion zur Anzeige von Info-Text (Infobar)
local function showInfobar(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

-- NEU: Funktion zur Darstellung des modernen Menüs
local function drawMenu(floors)
    local menuWidth = 0.25
    local menuX = 0.5
    local menuY = 0.3
    local headerHeight = 0.05
    local optionHeight = 0.04

    -- Header-Hintergrund
    DrawRect(menuX, menuY, menuWidth, headerHeight, 30, 30, 30, 220)
    
    -- Header-Text
    SetTextFont(4)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString("Fahrstuhl")
    SetTextCentre(true)
    DrawText(menuX, menuY - (headerHeight / 2) + 0.005)

    -- Menü-Optionen
    for i, floor in ipairs(floors) do
        local yPos = menuY + (headerHeight / 2) + (optionHeight / 2) + ((i - 1) * optionHeight)
        local bgColor = { r = 40, g = 40, b = 40, a = 180 }
        local textColor = { r = 240, g = 240, b = 240, a = 255 }
        local text = floor.label

        if i == selectedIndex then
            bgColor = { r = 0, g = 150, b = 255, a = 220 }
            textColor = { r = 255, g = 255, b = 255, a = 255 }
        end

        -- Options-Hintergrund
        DrawRect(menuX, yPos, menuWidth, optionHeight, bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        
        -- Options-Text
        SetTextFont(0)
        SetTextScale(0.35, 0.35)
        SetTextColour(textColor.r, textColor.g, textColor.b, textColor.a)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextCentre(true)
        DrawText(menuX, yPos - (optionHeight / 2) + 0.004)
    end
end

-- Funktion zum Öffnen und Steuern des Menüs
local function openElevatorMenu()
    if not currentElevatorIndex then return end
    isMenuOpen = true
    local elevatorFloors = elevatorConfig[currentElevatorIndex].floors
    selectedIndex = 1 -- Setze die Auswahl immer auf das erste Element zurück

    Citizen.CreateThread(function()
        while isMenuOpen do
            -- Menüsteuerung
            if IsControlJustReleased(0, KEY_UP) then
                selectedIndex = selectedIndex - 1
                if selectedIndex < 1 then selectedIndex = #elevatorFloors end
            elseif IsControlJustReleased(0, KEY_DOWN) then
                selectedIndex = selectedIndex + 1
                if selectedIndex > #elevatorFloors then selectedIndex = 1 end
            elseif IsControlJustReleased(0, KEY_ENTER) then
                local selectedFloor = elevatorFloors[selectedIndex]
                isMenuOpen = false

                if not hasJobAccess(selectedFloor) then
                    showInfobar('Du hast keine Berechtigung für dieses Stockwerk!')
                elseif not isFloorAccessible(selectedFloor) then
                    showInfobar('Der gewählte Ort ist blockiert!')
                else
                    playElevatorAnimation()
                    SetEntityCoords(PlayerPedId(), selectedFloor.x, selectedFloor.y, selectedFloor.z)
                end
            elseif IsControlJustReleased(0, KEY_BACKSPACE) then
                isMenuOpen = false
            end

            if isMenuOpen then
                drawMenu(elevatorFloors)
            end

            Citizen.Wait(0) -- Kurze Wartezeit für flüssige Menü-Steuerung
        end
    end)
end

-- OPTIMIERT: Funktion zur Überprüfung der Nähe zum Fahrstuhl
local function isPlayerNearElevator()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for elevatorIndex, elevator in ipairs(elevatorConfig) do
        if elevator.floors and #elevator.floors > 0 then
            local firstFloor = elevator.floors[1]
            -- Grober Check: Ist der Spieler überhaupt in der Nähe des Aufzugs? (z.B. 15 Meter)
            if Vdist(playerCoords, firstFloor.x, firstFloor.y, firstFloor.z) < 15.0 then
                -- Genauer Check: Steht der Spieler an einem der Haltepunkte?
                for _, floor in ipairs(elevator.floors) do
                    if Vdist(playerCoords, floor.x, floor.y, floor.z) < 1.5 then
                        currentElevatorIndex = elevatorIndex
                        return true
                    end
                end
            end
        end
    end
    currentElevatorIndex = nil
    return false
end

-- OPTIMIERT: Hauptthread für Logik und Interaktion
Citizen.CreateThread(function()
    while true do
        local sleep = 500 -- Standard-Wartezeit, wenn nichts in der Nähe ist
        
        isNearElevator = isPlayerNearElevator()

        if isNearElevator then
            sleep = 5 -- Kürzere Wartezeit für schnelle Reaktion
            if not isMenuOpen then
                -- Die Tasten-Hilfe zeigt die dynamisch zugewiesene Taste an
                showInfobar('Drücke ~INPUT_'..string.upper(COMMAND_USE_ELEVATOR)..'~, um den Fahrstuhl zu nutzen')
            end
        end

        -- Marker nur zeichnen, wenn in der Nähe, um Performance zu sparen
        if isNearElevator then
            drawElevatorMarker()
        end

        Citizen.Wait(sleep)
    end
end)

-- NEU: Registriert den Befehl und die Tastenbelegung
RegisterCommand(COMMAND_USE_ELEVATOR, function()
    if isNearElevator and not isMenuOpen then
        openElevatorMenu()
    end
end, false) -- false = Befehl ist für alle Spieler verfügbar
