ESX = exports['es_extended']:getSharedObject()

local currentTemperature = 15 -- Standard-Temperatur

--[[
  HINWEIS FÜR ENTWICKLER:

  Um die Temperatur von deinem Wetter-Skript aus zu aktualisieren,
  löse einfach dieses Server-Event aus.

  Beispiel in einem anderen Server-Skript:

  TriggerEvent("awaria_hud:updateTemperature", 25) -- Setzt die Temperatur auf 25°C
]]
RegisterNetEvent('awaria_hud:updateTemperature', function(newTemperature)
    if type(newTemperature) == 'number' then
        currentTemperature = newTemperature
    end
end)


-- Dieser Callback wird vom Client-Skript aufgerufen, um die Temperatur abzufragen.
ESX.RegisterServerCallback("weather:getTemperature", function(source, cb)
    cb(currentTemperature)
end)
