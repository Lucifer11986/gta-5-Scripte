-- Importiere die Config-Tabelle
Config = Config or {}

ESX = exports["es_extended"]:getSharedObject()

local isUIOpen = false
local eventsRegistered = false -- Flag, um zu überprüfen, ob Events bereits registriert sind

-- NPC-Modell
local npcModel = "s_m_m_postal_01"

-- Hilfsfunktion zur Überprüfung, ob ein Spieler ein Item besitzt
function HasPlayerItem(itemName)
    local hasItem = false
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.inventory then
        for i = 1, #playerData.inventory, 1 do
            if playerData.inventory[i].name == itemName and playerData.inventory[i].count > 0 then
                hasItem = true
                break
            end
        end
    end
    return hasItem
end

-- Funktion zum Spawnen der NPCs
local function spawnNPCs()
    for _, station in ipairs(Config.PostStations) do
        RequestModel(npcModel)
        while not HasModelLoaded(npcModel) do Citizen.Wait(10) end
        local npc = CreatePed(4, npcModel, station.x, station.y, station.z, station.heading, false, true)
        SetEntityHeading(npc, station.heading)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
    end
end

-- Funktion zur Überprüfung, ob der Spieler in der Nähe einer Poststation ist
local function isNearPostStation()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, station in ipairs(Config.PostStations) do
        if #(playerCoords - vector3(station.x, station.y, station.z)) < 2.0 then
            return true
        end
    end
    return false
end

-- Funktion zum Anzeigen von 3D-Text
local function drawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

-- Funktion zum Erstellen von Blips für Poststationen
local function createPostStationBlips()
    for _, station in ipairs(Config.PostStations) do
        local blip = AddBlipForCoord(station.x, station.y, station.z)
        SetBlipSprite(blip, Config.BlipSettings.sprite)
        SetBlipColour(blip, Config.BlipSettings.color)
        SetBlipScale(blip, Config.BlipSettings.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(blip)
    end
end

-- Funktion zur Registrierung von Events
local function registerEvents()
    if eventsRegistered then return end
    eventsRegistered = true

    RegisterNetEvent("postsystem:notifyMail")
    AddEventHandler("postsystem:notifyMail", function(mailEntry)
        if mailEntry and mailEntry.sender then
            ESX.ShowNotification(("📩 Neuer Brief von %s erhalten!"):format(mailEntry.sender))
        end
    end)

    RegisterCommand("openMail", function()
        if isUIOpen or not isNearPostStation() then return end
        local playerData = ESX.GetPlayerData()
        local isPolice = playerData.job and playerData.job.name == 'police'
        local isPostman = playerData.job and playerData.job.name == Config.PostmanJob.JobName
        local playerHasBox = HasPlayerItem('cardboard_box')
        ESX.TriggerServerCallback("postsystem:getMail", function(receivedMessages)
            ESX.TriggerServerCallback("postsystem:getStations", function(stations)
                ESX.TriggerServerCallback("postsystem:getPlayers", function(players)
                    ESX.TriggerServerCallback("postsystem:getFactions", function(factions)
                        ESX.TriggerServerCallback("postsystem:getInventory", function(inventory)
                            local dataToSend = {
                                action = "openUI", isPolice = isPolice, isPostman = isPostman,
                                stations = stations or {}, players = players or {}, factions = factions or {},
                                receivedMessages = receivedMessages or {}, inventory = inventory or {}, hasBox = playerHasBox
                            }
                            if isPolice then
                                ESX.TriggerServerCallback('postsystem:getPackagesForInspection', function(inspectionList)
                                    dataToSend.inspectionList = inspectionList or {}
                                    SendNUIMessage(dataToSend)
                                    SetNuiFocus(true, true)
                                    isUIOpen = true
                                end)
                            else
                                SendNUIMessage(dataToSend)
                                SetNuiFocus(true, true)
                                isUIOpen = true
                            end
                        end)
                    end)
                end)
            end)
        end)
    end, false)

    RegisterNUICallback("closeUI", function(data, cb) SetNuiFocus(false, false); isUIOpen = false; cb("ok") end)
    RegisterNUICallback("sendMail", function(data, cb) TriggerServerEvent("postsystem:sendMail", data); cb("ok") end)
    RegisterNUICallback("sendPackage", function(data, cb) TriggerServerEvent("postsystem:sendPackage", data); cb("ok") end)
    RegisterNUICallback("confiscatePackage", function(data, cb) if data and data.id then TriggerServerEvent('postsystem:confiscatePackage', data.id) end; cb('ok') end)
    RegisterNUICallback("deleteMail", function(data, cb) TriggerServerEvent("postsystem:deleteMail", data.id); cb("ok") end)
    RegisterKeyMapping("openMail", "Postsystem öffnen", "keyboard", "E")
end

-- Initialisierung
CreateThread(function()
    createPostStationBlips()
    spawnNPCs()
    registerEvents()
end)

-- Interaktions-Schleife
CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not isUIOpen then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local nearStation = false
            for _, station in ipairs(Config.PostStations) do
                local stationCoords = vector3(station.x, station.y, station.z)
                if #(playerCoords - stationCoords) < 2.0 then
                    nearStation = true
                    drawText3D(stationCoords, "~g~Drücke [E]~w~, um die Poststation zu öffnen")
                    if IsControlJustReleased(0, 38) then -- E
                        ExecuteCommand("openMail")
                    end
                    break
                end
            end
        end
    end
end)