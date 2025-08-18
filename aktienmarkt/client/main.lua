local isOpen = false

-- Öffne das NUI wenn die E-Taste gedrückt wird und der Spieler sich in der Nähe des Markers befindet
Citizen.CreateThread(function()
    local markerPos = vector3(251.66, 221.71, 106.29)
    local markerRadius = 2.0

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local distance = #(playerCoords - markerPos)

        if distance < markerRadius then
            DisplayHelpText("Drücke ~INPUT_CONTEXT~ um den Aktienmarkt zu öffnen.")

            if IsControlJustReleased(0, 51) then -- 51 ist die Standardtaste für 'E'
                SetNuiFocus(true, true)
                SendNUIMessage({ type = "ui", display = true })
                isOpen = true
            end
        end

        if isOpen then
            DisableControlAction(0, 1, true) -- Mausbewegung deaktivieren
            DisableControlAction(0, 2, true) -- Mausbewegung deaktivieren
            DisableControlAction(0, 142, true) -- Deaktiviere Nahkampfangriffen
            DisableControlAction(0, 18, true) -- Enter deaktivieren
            DisableControlAction(0, 322, true) -- ESC deaktivieren
        end

        Citizen.Wait(0)
    end
end)

-- Schließe das NUI wenn die Schließen oder Logout Taste im NUI gedrückt wird
RegisterNUICallback('closeNUI', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "ui", display = false })
    isOpen = false
end)

-- Aktien kaufen
RegisterNUICallback('buyStock', function(data, cb)
    -- Hier kannst du den Code zum Kauf der Aktie einfügen
    TriggerServerEvent('aktienmarkt:buyStock', data.stockId)
    cb('ok')
end)

-- Aktien verkaufen
RegisterNUICallback('sellStock', function(data, cb)
    -- Hier kannst du den Code zum Verkauf der Aktie einfügen
    TriggerServerEvent('aktienmarkt:sellStock', data.stockId)
    cb('ok')
end)

-- Filtere die Aktien nach Kategorie
RegisterNUICallback('filterStocks', function(data, cb)
    TriggerServerEvent('aktienmarkt:filterStocks', data.category)
    cb('ok')
end)

-- Empfangene gefilterte Aktien anzeigen
RegisterNetEvent('aktienmarkt:updateStocks')
AddEventHandler('aktienmarkt:updateStocks', function(stocks)
    SendNUIMessage({
        type = "updateStocks",
        stocks = stocks
    })
end)

-- Hilfstext anzeigen
function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Blip auf der Karte für den Aktienmarkt
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(251.66, 221.71, 106.29)

    SetBlipSprite(blip, 500) -- Blip-Symbol
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2) -- Farbe grün

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Aktienmarkt")
    EndTextCommandSetBlipName(blip)
end)
