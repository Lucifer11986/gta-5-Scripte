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
    -- Note: The decal type 247 is often used for this, but may need adjustment.
    -- Decal placement can be tricky, this is a basic implementation.
    local decal = AddDecal(
        247, -- type
        graffitiData.x, graffitiData.y, graffitiData.z, -- position
        0.0, 0.0, graffitiData.heading, -- rotation (normal)
        2.0, 2.0, 1.0, -- size
        1.0, 1.0, 1.0, 1.0, -- r,g,b,a
        0.0, -- timeout
        false, false, false -- permanent, on_vehicle, no_fading
    )

    -- Set the texture
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
    placeDecal(graffitiData)
end)

-- This event is triggered from client/spray_ui.lua after selecting a motif
RegisterNetEvent('graffiti:applySpray')
AddEventHandler('graffiti:applySpray', function(motif, color)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Raycast to find a wall in front of the player
    local offset = GetEntityForwardVector(playerPed) * 1.5
    local rayStart = playerCoords + vector3(0.0, 0.0, 0.5) -- Start ray from player's eye level
    local rayEnd = rayStart + offset

    local rayHandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, playerPed, 0)
    local _, hit, endCoords, surfaceNormal, _ = GetShapeTestResult(rayHandle)

    if hit then
        -- We found a surface, now we save it to the server
        -- The server will then trigger loadGraffiti for all clients
        local heading = GetGameplayCamRot(0).z
        TriggerServerEvent('graffiti:saveGraffiti', endCoords.x, endCoords.y, endCoords.z, heading, color, motif)
    else
        ESX.ShowNotification("Keine Wand zum Besprühen gefunden!")
    end
end)

-- This event is triggered from the server when a graffiti is removed
RegisterNetEvent('graffiti:deleteGraffiti')
AddEventHandler('graffiti:deleteGraffiti', function(coords)
    local decalToRemove = nil
    local indexToRemove = nil

    for i, graffiti in ipairs(createdGraffiti) do
        if #(graffiti.coords - coords) < 1.0 then
            decalToRemove = graffiti.decal
            indexToRemove = i
            break
        end
    end

    if decalToRemove then
        RemoveDecal(decalToRemove)
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
