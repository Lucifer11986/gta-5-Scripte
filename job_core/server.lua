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
