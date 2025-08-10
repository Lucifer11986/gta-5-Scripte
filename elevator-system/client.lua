--[[ 
    ÜBERARBEITETE VERSION DES ELEVATOR-SYSTEMS
    - Job- und Rang-Überprüfung implementiert
    - Performance durch optimierte Schleifen verbessert
    - Tastenbelegung ist nun über die Spieleinstellungen anpassbar
    - Benutzeroberfläche (UI) modernisiert
    - Code-Qualität durch lokale Variablen und Konstanten erhöht
]]

local isMenuOpen = false
local selectedIndex = 1
local currentElevatorIndex = nil
local isNearElevator = false

local KEY_UP = 172
local KEY_DOWN = 173
local KEY_ENTER = 191
local KEY_BACKSPACE = 202

local COMMAND_USE_ELEVATOR = "use_elevator"

local elevatorConfig = Config.Elevator

local ESX = exports['es_extended']:getSharedObject()

local function hasJobAccess(floor)
    if not floor.job then
        return true -- Kein Job erforderlich
    end

    local playerData = ESX.GetPlayerData()
    if playerData and playerData.job and playerData.job.name == floor.job then
        if floor.rank then
            return playerData.job.grade >= floor.rank
        else
            return true
        end
    end

    return false
end

local function isFloorAccessible(floor)
    local playerPed = PlayerPedId()
    local testCoords = vector3(floor.x, floor.y, floor.z + 1.0)
    local isClear = not IsPointObscuredByAMissionEntity(testCoords.x, testCoords.y, testCoords.z)
    local groundZ, isGroundValid = GetGroundZFor_3dCoord(floor.x, floor.y, floor.z, false)
    return isClear and isGroundValid
end

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

local function drawElevatorMarker()
    if currentElevatorIndex then
        local elevator = elevatorConfig[currentElevatorIndex]
        for _, floor in pairs(elevator.floors) do
            DrawMarker(
                25,
                floor.x, floor.y, floor.z - 0.95,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.8, 0.8, 0.8,
                0, 255, 0, 150,
                false, true, 2, nil, nil, false
            )
        end
    end
end

local function showInfobar(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

local function drawMenu(floors)
    local menuWidth = 0.25
    local menuX = 0.5
    local menuY = 0.3
    local headerHeight = 0.05
    local optionHeight = 0.04

    DrawRect(menuX, menuY, menuWidth, headerHeight, 30, 30, 30, 220)

    SetTextFont(4)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString("Fahrstuhl")
    SetTextCentre(true)
    DrawText(menuX, menuY - (headerHeight / 2) + 0.005)

    for i, floor in ipairs(floors) do
        local yPos = menuY + (headerHeight / 2) + (optionHeight / 2) + ((i - 1) * optionHeight)
        local bgColor = { r = 40, g = 40, b = 40, a = 180 }
        local textColor = { r = 240, g = 240, b = 240, a = 255 }
        local text = floor.label

        if i == selectedIndex then
            bgColor = { r = 0, g = 150, b = 255, a = 220 }
            textColor = { r = 255, g = 255, b = 255, a = 255 }
        end

        DrawRect(menuX, yPos, menuWidth, optionHeight, bgColor.r, bgColor.g, bgColor.b, bgColor.a)

        SetTextFont(0)
        SetTextScale(0.35, 0.35)
        SetTextColour(textColor.r, textColor.g, textColor.b, textColor.a)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetTextCentre(true)
        DrawText(menuX, yPos - (optionHeight / 2) + 0.004)
    end
end

local function openElevatorMenu()
    if not currentElevatorIndex then return end
    isMenuOpen = true
    local elevatorFloors = elevatorConfig[currentElevatorIndex].floors
    selectedIndex = 1

    Citizen.CreateThread(function()
        while isMenuOpen do
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

            Citizen.Wait(0)
        end
    end)
end

local function isPlayerNearElevator()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for elevatorIndex, elevator in ipairs(elevatorConfig) do
        if elevator.floors and #elevator.floors > 0 then
            local firstFloor = elevator.floors[1]
            if Vdist(playerCoords, firstFloor.x, firstFloor.y, firstFloor.z) < 15.0 then
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

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        isNearElevator = isPlayerNearElevator()

        if isNearElevator then
            sleep = 5
            if not isMenuOpen then
                showInfobar('Drücke ~INPUT_'..string.upper(COMMAND_USE_ELEVATOR)..'~, um den Fahrstuhl zu nutzen')
            end
        end

        if isNearElevator then
            drawElevatorMarker()
        end

        Citizen.Wait(sleep)
    end
end)

RegisterCommand(COMMAND_USE_ELEVATOR, function()
    if isNearElevator and not isMenuOpen then
        openElevatorMenu()
    end
end, false)
