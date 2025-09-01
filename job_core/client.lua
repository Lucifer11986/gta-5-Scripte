-- client.lua for job_core
print("job_core client script loaded")

-- Command to send an emergency call
RegisterCommand('notruf', function(source, args, rawCommand)
    local message = table.concat(args, " ")

    if message == nil or message == "" then
        -- In a real scenario, you would trigger a chat message here
        -- For example: TriggerEvent('chat:addMessage', { args = { '^1[DISPATCH]', 'You must provide a message for the call.' } })
        print("You must provide a message for the call.")
        return
    end

    -- Trigger the server event to create the call
    TriggerServerEvent('jobcore:newCall', message)
    -- Maybe add a confirmation message to the player
    -- TriggerEvent('chat:addMessage', { args = { '^2[DISPATCH]', 'Your call has been sent.' } })
    print("Your call has been sent.")
end, false) -- false makes it available to all players

-- #################################################################
-- ## UI Handling & Data Synchronization
-- #################################################################

local tabletOpen = false
local activeCalls = {}

-- Function to toggle the UI visibility
function setTabletVisible(visible)
    tabletOpen = visible
    SetNuiFocus(visible, visible)
    SendNuiMessage(json.encode({
        action = 'ui',
        show = visible
    }))

    -- If we are opening the tablet, send the latest calls list
    if visible then
        SendNuiMessage(json.encode({
            action = 'dispatchUpdate',
            calls = activeCalls
        }))
    end
end

-- Register a command to open the tablet
RegisterCommand('tablet', function()
    setTabletVisible(not tabletOpen)
end, false)

-- Listen for the server event that sends updated calls
RegisterNetEvent('jobcore:updateCalls')
AddEventHandler('jobcore:updateCalls', function(calls)
    activeCalls = calls
    -- If the tablet is currently open, push the update immediately
    if tabletOpen then
        SendNuiMessage(json.encode({
            action = 'dispatchUpdate',
            calls = activeCalls
        }))
    end
end)

-- Register NUI callback for when the player closes the UI with Escape
RegisterNuiCallbackType('close')
AddEventHandler('__cfx_nui:close', function(data, cb)
    setTabletVisible(false)
    cb('ok')
end)