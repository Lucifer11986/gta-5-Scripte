local ESX = exports['es_extended']:getSharedObject()

-- NUI-Callbacks aktivieren
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

-- Öffnet das Menü zur Anzeige der Kredite
RegisterNetEvent("boni_pruefung:openLoanMenu", function(loans)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openLoanMenu",
        loans = loans
    })
end)

-- Abrufen der Kredite vom Server
RegisterCommand("viewloans", function()
    ESX.TriggerServerCallback("boni_pruefung:getOutstandingLoans", function(loans)
        if loans and #loans > 0 then
            TriggerEvent("boni_pruefung:openLoanMenu", loans)
        else
            ESX.ShowNotification("Du hast keine ausstehenden Kredite.")
        end
    end)
end, false)

-- Animationen für Banker
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

-- Benachrichtigung bei Kreditvergabe
RegisterNetEvent("boni_pruefung:notifyCreditGiven", function(amount, totalPayback, interestRate)
    ESX.ShowNotification(("Du hast einen Kredit über $%d erhalten. Zinssatz: %d%%. Rückzahlung: $%d."):format(amount, interestRate * 100, totalPayback))
end)

-- Integration der UI für Kreditinformationen
RegisterNUICallback("requestCreditInfo", function()
    ESX.TriggerServerCallback("boni_pruefung:getPlayerCreditInfo", function(data)
        if data then
            SendNUIMessage({
                action = "updateCreditInfo",
                creditInfo = data
            })
        else
            SendNUIMessage({
                action = "updateCreditInfo",
                creditInfo = "Keine Daten gefunden."
            })
        end
    end)
end)

-- Animationen stoppen
RegisterCommand("stopanimation", function()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end, false)

-- Kreditrückzahlung aus dem Client-Skript
RegisterCommand("repayloan", function(_, args)
    local amount = tonumber(args[1])
    if not amount or amount <= 0 then
        ESX.ShowNotification("Bitte gib einen gültigen Betrag ein. Nutzung: /repayloan [Betrag]")
        return
    end

    TriggerServerEvent("boni_pruefung:payLoan", amount)
end, false)

-- Funktion, um Nachrichten mit Timeout anzuzeigen
function ShowTemporaryMessage(msg, duration)
    TriggerEvent("chat:addMessage", {
        args = { "SYSTEM", msg }
    })

    -- Timeout zum Entfernen der Nachricht
    Citizen.CreateThread(function()
        Citizen.Wait(duration)
        TriggerEvent("chat:clear")
    end)
end