local inMarker = false
local currentMarket = nil

-- Fallback-Funktion, falls vom Framework nicht bereitgestellt
local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Erstelle die Blips beim Start des Skripts
CreateThread(function()
    for _, market in ipairs(Config.MarketLocations) do
        if market.blip then
            local blip = AddBlipForCoord(market.coords)
            SetBlipSprite(blip, Config.BlipSettings.sprite)
            SetBlipDisplay(blip, Config.BlipSettings.display)
            SetBlipScale(blip, Config.BlipSettings.scale)
            SetBlipColour(blip, Config.BlipSettings.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.BlipSettings.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Haupt-Thread für Marker- und Distanzprüfung
CreateThread(function()
    while true do
        Wait(500)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local wasInMarker = inMarker
        inMarker = false
        currentMarket = nil

        for i, market in ipairs(Config.MarketLocations) do
            local distance = #(playerCoords - market.coords)

            if distance < 10.0 then
                DrawMarker(2, market.coords.x, market.coords.y, market.coords.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                if distance < 2.0 then
                    inMarker = true
                    currentMarket = i
                end
            end
        end

        if wasInMarker ~= inMarker then
            Wait(0)
        end
    end
end)

-- Thread für die Interaktionsabfrage
CreateThread(function()
    while true do
        Wait(5)
        if inMarker then
            DrawText3D(Config.MarketLocations[currentMarket].coords.x, Config.MarketLocations[currentMarket].coords.y, Config.MarketLocations[currentMarket].coords.z, "[E] - Kunsthandel öffnen")
            if IsControlJustReleased(0, Config.InteractionKey) then
                OpenMarketMenu()
            end
        else
            Wait(500)
        end
    end
end)
