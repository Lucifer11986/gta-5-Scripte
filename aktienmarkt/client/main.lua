ESX = nil
local isOpen = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Marker und Interaktion
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local marketPos = vector3(config.MarketPosition.x, config.MarketPosition.y, config.MarketPosition.z)
        local distance = #(playerCoords - marketPos)

        if distance < config.markerDistance then
            -- Draw Marker
            DrawMarker(
                config.Marker.type,
                marketPos.x, marketPos.y, marketPos.z - 0.98,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                config.Marker.scale.x, config.Marker.scale.y, config.Marker.scale.z,
                config.Marker.color.r, config.Marker.color.g, config.Marker.color.b, config.Marker.color.a,
                false, true, 2, nil, nil, false
            )

            -- Show Help Text and Handle Input
            DisplayHelpText("Drücke ~INPUT_CONTEXT~ um den Aktienmarkt zu öffnen.")
            if IsControlJustReleased(0, 51) then -- 51 = E
                openNUI()
            end
        end
    end
end)

-- Blip auf der Karte
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(config.MarketPosition.x, config.MarketPosition.y, config.MarketPosition.z)

    SetBlipSprite(blip, config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, config.Blip.scale)
    SetBlipColour(blip, config.Blip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(config.Blip.name)
    EndTextCommandSetBlipName(blip)
end)


function openNUI()
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "ui", display = true })
    -- Request initial data
    TriggerServerEvent('aktienmarkt:getStocks', 'firmen') -- Load 'firmen' by default
    TriggerServerEvent('aktienmarkt:getMyStocks')
end

function closeNUI()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "ui", display = false })
end

-- NUI Callbacks
RegisterNUICallback('closeNUI', function(data, cb)
    closeNUI()
    cb('ok')
end)

RegisterNUICallback('buyStock', function(data, cb)
    if data.stockName and data.amount and tonumber(data.amount) > 0 then
        TriggerServerEvent('aktienmarkt:buyStock', data.stockName, tonumber(data.amount))
    end
    cb('ok')
end)

RegisterNUICallback('sellStock', function(data, cb)
    if data.stockName and data.amount and tonumber(data.amount) > 0 then
        TriggerServerEvent('aktienmarkt:sellStock', data.stockName, tonumber(data.amount))
    end
    cb('ok')
end)

RegisterNUICallback('filterStocks', function(data, cb)
    if data.category then
        TriggerServerEvent('aktienmarkt:getStocks', data.category)
    end
    cb('ok')
end)

-- Net Events from Server
RegisterNetEvent('aktienmarkt:updateStocks')
AddEventHandler('aktienmarkt:updateStocks', function(stocks)
    SendNUIMessage({
        type = "updateStocks",
        stocks = stocks
    })
end)

RegisterNetEvent('aktienmarkt:updateMyStocks')
AddEventHandler('aktienmarkt:updateMyStocks', function(myStocks)
    SendNUIMessage({
        type = "updateMyStocks",
        stocks = myStocks
    })
end)

-- Hilfstext anzeigen
function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Disable controls while NUI is open
Citizen.CreateThread(function()
    while true do
        if isOpen then
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 18, true) -- Enter
            DisableControlAction(0, 322, true) -- ESC
            DisableControlAction(2, 200, true) -- ESC
        end
        Citizen.Wait(0)
    end
end)
