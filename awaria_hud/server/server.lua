ESX = exports['es_extended']:getSharedObject()

-- Dieser Callback kümmert sich jetzt nur noch um die Temperatur.
ESX.RegisterServerCallback('awaria_hud:getTemperature', function(source, cb)
    local temperature = nil
    
    -- Holt die Temperatur vom Wetter-Skript
    local weatherExport = exports['weather_seasons']
    if weatherExport and weatherExport.GetCurrentTemperature then
        temperature = weatherExport:GetCurrentTemperature()
    end

    cb(temperature)
end)