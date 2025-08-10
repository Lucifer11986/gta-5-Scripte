ESX = exports["es_extended"]:getSharedObject()

local isPlacingMailbox = false
local placedMailboxes = {} -- Will now store {id, obj, owner}
local placementObject = nil
local isLockerUIOpen = false
local currentMailboxId = nil

-- Funktion zum Zeichnen von Texthinweisen
local function DrawHelpText(text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.0, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.95)
end

-- Startet den Platzierungsmodus
RegisterNetEvent('postsystem:startMailboxPlacement')
AddEventHandler('postsystem:startMailboxPlacement', function()
    if isPlacingMailbox then return end
    isPlacingMailbox = true
    local model = GetHashKey(Config.MailboxProp)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    placementObject = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    SetEntityCollision(placementObject, false, false)

    CreateThread(function()
        local heading = GetEntityHeading(playerPed)
        while isPlacingMailbox do
            Wait(0)
            DrawHelpText("Drücke [E] zum Platzieren, [G] zum Abbrechen. [LINKS]/[RECHTS] zum Drehen.")
            if IsControlPressed(0, 174) then heading = heading - 1.5 end
            if IsControlPressed(0, 175) then heading = heading + 1.5 end
            local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.2, -1.0)
            SetEntityCoords(placementObject, pos.x, pos.y, pos.z, false, false, false, true)
            SetEntityHeading(placementObject, heading)
            if IsControlJustReleased(0, 38) then -- E
                local finalCoords = GetEntityCoords(placementObject)
                local finalHeading = GetEntityHeading(placementObject)
                TriggerServerEvent('postsystem:placeMailbox', {x = finalCoords.x, y = finalCoords.y, z = finalCoords.z, h = finalHeading})
                isPlacingMailbox = false
            end
            if IsControlJustReleased(0, 47) then -- G
                isPlacingMailbox = false
                ESX.ShowNotification("Platzierung abgebrochen.")
            end
        end
        if DoesEntityExist(placementObject) then DeleteEntity(placementObject) end
        placementObject = nil
    end)
end)

-- Funktion zum Spawnen eines einzelnen Briefkastens
function spawnMailboxObject(mailbox)
    local model = GetHashKey(Config.MailboxProp)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local obj = CreateObject(model, mailbox.location.x, mailbox.location.y, mailbox.location.z, false, true, false)
    SetEntityHeading(obj, mailbox.location.h)
    FreezeEntityPosition(obj, true)
    table.insert(placedMailboxes, {id = mailbox.id, obj = obj, owner = mailbox.owner_identifier})
end

-- Spawne einen neuen Briefkasten
RegisterNetEvent('postsystem:spawnNewMailbox')
AddEventHandler('postsystem:spawnNewMailbox', function(mailboxData)
    spawnMailboxObject(mailboxData)
end)

-- Lade alle platzierten Briefkästen beim Start
CreateThread(function()
    ESX.TriggerServerCallback('postsystem:getPlacedMailboxes', function(mailboxes)
        if mailboxes then
            for _, mailbox in ipairs(mailboxes) do
                spawnMailboxObject(mailbox)
            end
        end
    end)
end)

-- Interaktions-Schleife
CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()
        if ESX.GetPlayerData().identifier then
            local playerCoords = GetEntityCoords(playerPed)
            local myIdentifier = ESX.GetPlayerData().identifier
            local nearbyOwnedMailbox = nil

            for _, mailbox in ipairs(placedMailboxes) do
                if #(playerCoords - GetEntityCoords(mailbox.obj)) < 1.5 then
                    if mailbox.owner == myIdentifier then
                        nearbyOwnedMailbox = mailbox
                        break
                    end
                end
            end

            if nearbyOwnedMailbox and not isLockerUIOpen then
                ESX.ShowHelpNotification("Drücke [E], um deinen Briefkasten zu öffnen.")
                if IsControlJustReleased(0, 38) then -- E
                    currentMailboxId = nearbyOwnedMailbox.id
                    ESX.TriggerServerCallback('postsystem:getMailboxInventory', function(inventory)
                        if inventory then
                            isLockerUIOpen = true
                            SetNuiFocus(true, true)
                            SendNUIMessage({action = "openLocker", inventory = inventory})
                        else
                            ESX.ShowNotification("Fehler beim Öffnen des Briefkastens.")
                        end
                    end, nearbyOwnedMailbox.id)
                end
            end
        end
    end
end)

-- NUI Callbacks für das Schließfach
RegisterNUICallback('closeLocker', function(data, cb)
    isLockerUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('takeFromMailbox', function(data, cb)
    if currentMailboxId and data.itemName then
        TriggerServerEvent('postsystem:takeFromMailbox', currentMailboxId, data.itemName)
    end
    cb('ok')
end)

-- Event zum Aktualisieren des UI
RegisterNetEvent('postsystem:updateMailboxInventory')
AddEventHandler('postsystem:updateMailboxInventory', function(newInventory)
    if isLockerUIOpen then
        SendNUIMessage({action = "openLocker", inventory = newInventory})
    end
end)
