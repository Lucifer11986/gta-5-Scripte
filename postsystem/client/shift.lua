ESX = exports["es_extended"]:getSharedObject()

local jobNPC = nil
local npcModel = "s_m_m_postal_01"

-- Funktion zum Spawnen des Job-NPCs und des Blips
local function setupJobLocation()
    local jobLocation = Config.PostmanJob.JobLocation
    
    -- Blip
    local blip = AddBlipForCoord(jobLocation.x, jobLocation.y, jobLocation.z)
    SetBlipSprite(blip, 408)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Postboten-Job")
    EndTextCommandSetBlipName(blip)

    -- NPC
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do Wait(10) end
    jobNPC = CreatePed(4, GetHashKey(npcModel), jobLocation.x, jobLocation.y, jobLocation.z - 1.0, jobLocation.heading, false, true)
    FreezeEntityPosition(jobNPC, true)
    SetEntityInvincible(jobNPC, true)
    SetBlockingOfNonTemporaryEvents(jobNPC, true)
end

-- Interaktionspunkt für Schichtsystem
CreateThread(function()
    setupJobLocation()

    while true do
        local wait = 1000
        if jobNPC then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local npcCoords = GetEntityCoords(jobNPC)
            local distance = #(playerCoords - npcCoords)

            if distance < 5.0 then
                wait = 5 -- Loop faster when near
                if distance < 1.5 then
                    local playerJob = ESX.GetPlayerData().job
                    if playerJob and playerJob.name == Config.PostmanJob.JobName then
                        ESX.ShowHelpNotification("Drücke [E], um deine Schicht zu beenden.")
                    else
                        ESX.ShowHelpNotification("Drücke [E], um als Postbote zu arbeiten.")
                    end

                    if IsControlJustReleased(0, 38) then -- E
                        if playerJob and playerJob.name == Config.PostmanJob.JobName then
                            TriggerServerEvent('postsystem:endPostmanShift')
                        else
                            TriggerServerEvent('postsystem:startPostmanShift')
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)

-- Event zum Anziehen der Uniform
RegisterNetEvent('postsystem:setUniform')
AddEventHandler('postsystem:setUniform', function()
    local playerPed = PlayerPedId()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        local uniform = Config.PostmanJob.Uniform
        if skin.sex == 0 then -- Male
            TriggerEvent('skinchanger:loadClothes', skin, uniform.male)
        else -- Female
            TriggerEvent('skinchanger:loadClothes', skin, uniform.female)
        end
    end)
end)

-- Event zum Wiederherstellen der Kleidung
RegisterNetEvent('postsystem:restoreClothing')
AddEventHandler('postsystem:restoreClothing', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end)