-- Lade die Konfiguration
local eggLocations = Config.EggLocations or {}
local foundEggs = {}
local eggObjects = {}
local eggBlips = {}
local activeTexts = {}

-- Liste der Osterei-Modelle
local eggModels = {
    "core_egg01",
    "core_egg02",
    "core_egg03",
    "core_egg04",
    "core_egg05",
    "core_egg06"
}

-- Debug: Sicherstellen, dass die Config geladen wurde
if #eggLocations == 0 then
    print("[Oster-Event] Fehler: Keine Eier in Config.EggLocations gefunden!")
end

RegisterNetEvent("easter_event:updateEggs")
AddEventHandler("easter_event:updateEggs", function(eggs)
    foundEggs = eggs

    -- Entferne gefundene Eier von der Karte
    for index, _ in pairs(foundEggs) do
        if eggObjects[index] then
            DeleteObject(eggObjects[index])
            eggObjects[index] = nil
        end
        if eggBlips[index] then
            RemoveBlip(eggBlips[index])
            eggBlips[index] = nil
        end
        activeTexts[index] = nil -- 3D-Text entfernen
    end
end)

-- Modelle vorladen
CreateThread(function()
    for _, model in ipairs(eggModels) do
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(500)
            print("[Oster-Event] Warte auf Modell: " .. model)
        end
        print("[Oster-Event] Modell geladen: " .. model)
    end
end)

-- Eier auf der Karte anzeigen und einsammeln
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for index, eggPos in ipairs(eggLocations) do
            if not foundEggs[index] and #(playerCoords - eggPos) < 3.0 then
                activeTexts[index] = {x = eggPos.x, y = eggPos.y, z = eggPos.z}
                DrawText3D(eggPos.x, eggPos.y, eggPos.z, "🛑 Drücke [E], um das Osterei zu sammeln")

                if IsControlJustReleased(0, 38) then -- Taste "E"
                    PlayEggPickupAnimation()
                    Wait(1000)
                    TriggerServerEvent("easter_event:findEgg", index)
                end
            else
                activeTexts[index] = nil -- 3D-Text löschen, wenn Ei gefunden wurde
            end
        end
    end
end)

-- 3D-Text Funktion
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local dist = #(p - vector3(x, y, z))
    local scale = 1 / (dist * 1) * 0.3
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Eier auf der Karte generieren
RegisterNetEvent("easter_event:createEggs")
AddEventHandler("easter_event:createEggs", function(eggs)
    if type(eggs) ~= "table" then
        print("[ERROR] Eier-Daten sind ungültig! Erwartet eine Tabelle.")
        return
    end

    -- Entferne alte Eier, falls vorhanden
    for _, obj in pairs(eggObjects) do
        DeleteObject(obj)
    end
    eggObjects = {}

    -- Entferne alte Blips
    for _, blip in pairs(eggBlips) do
        RemoveBlip(blip)
    end
    eggBlips = {}

    for index, egg in ipairs(eggs) do
        if not foundEggs[index] then
            local model = eggModels[math.random(#eggModels)]
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(100)
            end

            -- Ei erstellen
            local obj = CreateObject(GetHashKey(model), egg.x, egg.y, egg.z, true, true, false)
            SetEntityAsMissionEntity(obj, true, true)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)

            if DoesEntityExist(obj) then
                print("[Oster-Event] Ei erfolgreich erstellt an: ", egg.x, egg.y, egg.z)
                eggObjects[index] = obj
            else
                print("[Oster-Event] Fehler: Ei konnte nicht gespawnt werden an ", egg.x, egg.y, egg.z)
            end

            -- Blip hinzufügen
            local blip = AddBlipForCoord(egg.x, egg.y, egg.z)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 2) -- Grün
            SetBlipScale(blip, 0.8)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Osterei")
            EndTextCommandSetBlipName(blip)
            eggBlips[index] = blip
        end
    end
end)

-- Animation beim Aufheben des Eis
function PlayEggPickupAnimation()
    local playerPed = PlayerPedId()
    local dict = "pickup_object" -- Animations-Dictionary
    local anim = "pickup_low" -- Aufheben-Animation

    -- Lade die Animation
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end

    -- Animation abspielen
    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, 1000, 49, 0, false, false, false)
    Wait(2000) -- Wartezeit für Animation
    ClearPedTasks(playerPed)
end

-- Bei Serverstart Eier generieren
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('easter_event:spawnEggs')
    end
end)
