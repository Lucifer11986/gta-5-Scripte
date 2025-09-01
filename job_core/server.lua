-- server.lua for job_core
print("job_core server script loaded")

local ActiveCalls = {}
local callIdCounter = 1

-- This event is triggered by a client who sends a new emergency call
RegisterNetEvent('jobcore:newCall', function(message)
    local source = source -- The player who triggered the event

    -- Get player's coordinates
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    -- Create a new call object
    local newCall = {
        id = callIdCounter,
        message = message,
        coords = coords,
        source = source,
        time = os.time() -- Use a timestamp for the call
    }

    -- Add the new call to the list
    table.insert(ActiveCalls, newCall)
    callIdCounter = callIdCounter + 1

    -- Broadcast the updated list of calls to all clients
    TriggerClientEvent('jobcore:updateCalls', -1, ActiveCalls)

    print(('[job_core] New call received from player %s: "%s"'):format(source, message))
end)

-- A function to remove a call, can be triggered by jobs later
-- We will implement the trigger for this later (e.g. from the UI)
function removeCall(id)
    local newCalls = {}
    for i, call in ipairs(ActiveCalls) do
        if call.id ~= id then
            table.insert(newCalls, call)
        end
    end
    ActiveCalls = newCalls
    -- Broadcast the change
    TriggerClientEvent('jobcore:updateCalls', -1, ActiveCalls)
end


-- #################################################################
-- ## Duty System
-- #################################################################

local OnDutyPlayers = {} -- Using a dictionary/map for quick lookups { [source] = "PlayerName" }

-- Function to broadcast the updated duty list to all clients
local function broadcastDutyStatus()
    local dutyListForClient = {}
    for source, name in pairs(OnDutyPlayers) do
        table.insert(dutyListForClient, {source = source, name = name})
    end
    TriggerClientEvent('jobcore:updateDutyStatus', -1, dutyListForClient)
end

-- Event to toggle duty status
RegisterNetEvent('jobcore:toggleDuty', function()
    local source = source
    local playerName = GetPlayerName(source)

    if OnDutyPlayers[source] then
        -- Player is going off-duty
        OnDutyPlayers[source] = nil
        print(('[job_core] Player %s (%s) is now off-duty.'):format(playerName, source))
    else
        -- Player is going on-duty
        OnDutyPlayers[source] = playerName
        print(('[job_core] Player %s (%s) is now on-duty.'):format(playerName, source))
    end

    -- Broadcast the changes
    broadcastDutyStatus()
end)

-- Handle player disconnects
AddEventHandler('playerDropped', function(reason)
    local source = source
    if OnDutyPlayers[source] then
        OnDutyPlayers[source] = nil
        print(('[job_core] Player %s dropped, removed from duty.'):format(GetPlayerName(source), source))
        -- Broadcast the changes
        broadcastDutyStatus()
    end
end)

-- When a player joins, send them the current duty list so they are up to date
-- This is important because they won't get updates until someone changes state
AddEventHandler('playerJoining', function(name, setKickReason, deferrals)
    local source = source
    -- Using a slight delay to ensure the client script is ready
    Citizen.CreateThread(function()
        Citizen.Wait(10000) -- 10 seconds delay to ensure client is fully loaded
        broadcastDutyStatus() -- Resync all clients, simpler than targeting one
    end)
end)
