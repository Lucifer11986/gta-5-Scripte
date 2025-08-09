local ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- NUI-Callbacks
RegisterNUICallback("closeUI", function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeUI" })
end)

RegisterNUICallback("payLoan", function(data)
    local amount = tonumber(data.amount)
    if not amount or amount <= 0 then
        ESX.ShowNotification("Ungültiger Betrag!")
        return
    end

    TriggerServerEvent("boni_pruefung:payLoan", amount)
end)

-- This callback is now used to get all loan info for the UI
RegisterNUICallback("requestCreditInfo", function()
    ESX.TriggerServerCallback("boni_pruefung:getOutstandingLoans", function(data)
        SendNUIMessage({
            action = "updateCreditInfo",
            creditInfo = data or {} -- Send empty table if no data
        })
    end)
end)


-- Event from server to show a notification
RegisterNetEvent("boni_pruefung:showNotification", function(message)
    ESX.ShowNotification(message)
end)


-- Event to open the loan menu (likely triggered by a command or item)
RegisterNetEvent("boni_pruefung:openLoanMenu", function(loans)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openLoanMenu",
        loans = loans
    })
end)

-- Command to open the loan menu
RegisterCommand("viewloans", function()
    ESX.TriggerServerCallback("boni_pruefung:getOutstandingLoans", function(loans)
        if loans and #loans > 0 then
            -- Assuming the menu should open when loans are available
            TriggerEvent("boni_pruefung:openLoanMenu", loans)
        else
            ESX.ShowNotification("Du hast keine ausstehenden Kredite.")
        end
    end)
end, false)


-- Animation commands remain for banker roleplay
function playBankerAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("amb@prop_human_seat_chair@male@generic@idle_a")
    while not HasAnimDictLoaded("amb@prop_human_seat_chair@male@generic@idle_a") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "amb@prop_human_seat_chair@male@generic@idle_a", "idle_a", 8.0, 8.0, -1, 49, 0, false, false, false)
end

RegisterCommand("startbankeranim", function()
    playBankerAnimation()
end, false)

RegisterCommand("stopanimation", function()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end, false)
