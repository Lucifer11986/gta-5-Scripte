ESX = exports['es_extended']:getSharedObject()

-- Server-seitige Logik wurde entfernt, da sie nicht verwendet wurde oder fehlerhaft war.
-- Der Client-Code wurde angepasst, um serverseitige Aufrufe zu entfernen, die hier zuvor hätten sein sollen.
-- Insbesondere wurde der Callback "weather:getTemperature" vom Client erwartet, war hier aber nicht implementiert.
