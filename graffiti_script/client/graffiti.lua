ESX = exports["es_extended"]:getSharedObject()

local graffitiTextureDict = "graffiti_textures"
local createdGraffiti = {} -- Store data and handles of created graffiti

-- Function to place a decal on the wall
local function placeDecal(graffitiData)
    -- Request the texture dictionary
    RequestStreamedTextureDict(graffitiTextureDict, false)
    while not HasStreamedTextureDictLoaded(graffitiTextureDict) do
        Wait(100)
    end

    -- Create the decal
    local decal = AddDecal(247, graffitiData.x, graffitiData.y, graffitiData.z, 0.0, 0.0, graffitiData.heading, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, false, false, false)
    SetDecalTexture(decal, graffitiTextureDict, graffitiData.image)
    
    -- Store the decal handle and data
    table.insert(createdGraffiti, {
        decal = decal,
        coords = vector3(graffitiData.x, graffitiData.y, graffitiData.z)
    })
end

-- This event is triggered from the server for each graffiti in the database
RegisterNetEvent('graffiti:loadGraffiti')
AddEventHandler('graffiti:loadGraffiti', function(graffitiData)
    -- To prevent duplicates, remove any existing graffiti at the same spot before adding
    for i = #createdGraffiti, 1, -1 do
        if #(createdGraffiti[i].coords - vector3(graffitiData.x, graffitiData.y, graffitiData.z)) < 0.1 then
            RemoveDecal(createdGraffiti[i].decal)
            table.remove(createdGraffiti, i)
        end
    end
    placeDecal(graffitiData)
end)

-- This event is triggered from client/spray_ui.lua after selecting a motif
RegisterNetEvent('graffiti:applySpray')
AddEventHandler('graffiti:applySpray', function(motif, color)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Raycast to find a wall in front of the player
    local offset = GetEntityForwardVector(playerPed) * 1.5
    local rayStart = playerCoords + vector3(0.0, 0.0, 0.5)
    local rayEnd = rayStart + offset

    local rayHandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, playerPed, 0)
    local _, hit, endCoords, _, _ = GetShapeTestResult(rayHandle)

    if hit then
        local heading = GetGameplayCamRot(0).z
        local graffitiToOverwrite = nil

        if Config.EnableGraffitiWars then
            local overwriteThreshold = 1.5
            for _, existingGraffiti in ipairs(createdGraffiti) do
                if #(endCoords - existingGraffiti.coords) < overwriteThreshold then
                    graffitiToOverwrite = existingGraffiti.coords
                    break
                end
            end
        end
        
        TriggerServerEvent('graffiti:saveGraffiti', endCoords, heading, color, motif, graffitiToOverwrite)
    else
        ESX.ShowNotification("Keine Wand zum Besprühen gefunden!")
    end
end)

-- This event is triggered from the server when a graffiti is removed
RegisterNetEvent('graffiti:deleteGraffiti')
AddEventHandler('graffiti:deleteGraffiti', function(coords)
    local indexToRemove = nil
    for i, graffiti in ipairs(createdGraffiti) do
        if #(graffiti.coords - coords) < 1.0 then
            RemoveDecal(graffiti.decal)
            indexToRemove = i
            break
        end
    end
    if indexToRemove then
        table.remove(createdGraffiti, indexToRemove)
    end
end)

-- When the resource is stopped, remove all decals
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, graffiti in ipairs(createdGraffiti) do
            RemoveDecal(graffiti.decal)
        end
    end
end)