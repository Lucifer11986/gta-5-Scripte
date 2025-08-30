ESX = exports['es_extended']:getSharedObject()

-- Dieser Callback kümmert sich jetzt nur noch um die Temperatur.
ESX.RegisterServerCallback('awaria_hud:getTemperature', function(source, cb)
    local temp = exports['weather_seasons']:GetCurrentTemperature()
    cb(temp or 15) -- Fallback auf 15 Grad

    
    -- Holt die Temperatur vom Wetter-Skript
    local weatherExport = exports['weather_seasons']
    if weatherExport and weatherExport.GetCurrentTemperature then
        temperature = weatherExport:GetCurrentTemperature()
    end

    cb(temperature)
end)