local isSummerMarketOpen = false

-- Funktion zum Öffnen des Sommermarktes
function OpenSummerMarket()
    isSummerMarketOpen = true
    -- Marktplatz-UI aktivieren
    TriggerEvent("notification", "Der Sommermarkt ist jetzt geöffnet! Besuche uns für exklusive Items.")
end

-- Funktion zum Schließen des Marktes (nach einer bestimmten Zeit)
function CloseSummerMarket()
    isSummerMarketOpen = false
    TriggerEvent("notification", "Der Sommermarkt hat geschlossen. Schau bald wieder vorbei!")
end

-- Interaktion mit dem Sommermarkt (Kaufen, Verkaufen)
RegisterNetEvent("interact_with_summer_market")
AddEventHandler("interact_with_summer_market", function()
    if isSummerMarketOpen then
        -- Zeige UI für Kauf/Verkauf
        TriggerEvent("open_market_ui")  -- Funktion zum Öffnen der Kauf-UI
    else
        TriggerEvent("notification", "Der Sommermarkt ist momentan geschlossen.")
    end
end)

-- Funktion zur Anzeige der saisonalen Items und Preise
function ShowMarketItems()
    local marketItems = {
        {name = "Sonnenbrille", price = 100},
        {name = "Eiscreme", price = 50},
        {name = "Badehose", price = 120},
        {name = "Frisches Obst", price = 30}
    }
    
    -- UI mit Items anzeigen
    TriggerEvent("open_item_ui", marketItems)
end
