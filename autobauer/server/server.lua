ESX, QBCore = nil, nil

-- =========================
-- Framework Detection
-- =========================
if Config.Framework == "ESX" then
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
        print("^2[Autobauer]^0 ESX geladen!")
        RegisterESXCallbacksAndEvents()
    end)
elseif Config.Framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
    print("^2[Autobauer]^0 QBCore geladen!")
    RegisterQBCoreCallbacksAndEvents()
end

-- =========================
-- Helferfunktionen
-- =========================
function IsAllowedJob(src)
    if Config.Framework == "ESX" and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        local jobName = xPlayer.job and xPlayer.job.name
        return Config.AllowedFactoryJobs[jobName] or false
    elseif Config.Framework == "QBCore" and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local jobName = Player.PlayerData.job and Player.PlayerData.job.name
        return Config.AllowedFactoryJobs[jobName] or false
    end
    return false
end

function HasMaterials(vehicleName, cb)
    local vehicle = nil
    for _,v in pairs(Config.Vehicles) do
        if v.name == vehicleName then
            vehicle = v
            break
        end
    end
    if not vehicle then return cb(false) end

    ExecuteQuery("SELECT * FROM job_storage_materials", {}, function(result)
        local hasAll = true
        for mat,amount in pairs(vehicle.requirements) do
            local found = false
            for i=1,#result do
                if result[i].item_name == mat and result[i].quantity >= amount then
                    found = true
                    break
                end
            end
            if not found then hasAll = false break end
        end
        cb(hasAll)
    end)
end

function TakeMaterials(vehicleName, cb)
    local vehicle = nil
    for _,v in pairs(Config.Vehicles) do
        if v.name == vehicleName then
            vehicle = v
            break
        end
    end
    if not vehicle then return cb(false) end

    for mat,amount in pairs(vehicle.requirements) do
        ExecuteQuery("UPDATE job_storage_materials SET quantity = quantity - ? WHERE item_name = ?", {amount, mat})
    end
    cb(true)
end

-- =========================
-- ESX Callbacks & Events
-- =========================
function RegisterESXCallbacksAndEvents()
    -- Fahrzeuge aus DB
    ESX.RegisterServerCallback('autobauer:server:getVehicles', function(source, cb)
        if not IsAllowedJob(source) then cb({}) return end
        ExecuteQuery("SELECT * FROM vehicles", {}, function(result)
            local vehicles = {}
            for _, v in ipairs(result) do
                table.insert(vehicles, {
                    model = v.model,
                    label = v.name,
                    category = v.category,
                    fuel_type = v.fuel_type,
                    price = v.price or 0
                })
            end
            cb(vehicles)
        end)
    end)

    -- Lager
    ESX.RegisterServerCallback('autobauer:server:getStorageCars', function(source, cb)
        if not IsAllowedJob(source) then cb({}) return end
        ExecuteQuery("SELECT * FROM job_storage_cars", {}, cb)
    end)

    -- Materialien
    ESX.RegisterServerCallback('autobauer:server:getMaterials', function(source, cb)
        if not IsAllowedJob(source) then cb({}) return end
        ExecuteQuery("SELECT * FROM job_storage_materials", {}, cb)
    end)

    -- Produktion starten
    RegisterNetEvent('autobauer:server:startProduction', function(vehicleName, customPrice)
        local src = source
        if not IsAllowedJob(src) then
            TriggerClientEvent('esx:showNotification', src, "Du hast keinen Zugriff auf diese Werkstatt!")
            return
        end

        HasMaterials(vehicleName, function(has)
            if not has then
                TriggerClientEvent('esx:showNotification', src, "Nicht genügend Materialien!")
                return
            end

            TakeMaterials(vehicleName, function(success)
                if not success then
                    TriggerClientEvent('esx:showNotification', src, "Fehler beim Abziehen der Materialien!")
                    return
                end

                local vehicleData = nil
                for _,v in ipairs(Config.Vehicles) do
                    if v.name == vehicleName then
                        vehicleData = v
                        break
                    end
                end
                if not vehicleData then return end

                local productionTime = Config.ProductionTime[vehicleName] or 600
                TriggerClientEvent('esx:showNotification', src, "Produktion gestartet: "..vehicleName.." ("..productionTime.." Sekunden)")

                SetTimeout(productionTime * 1000, function()
                    local plate = "AUTO"..math.random(1000,9999)
                    local priceToUse = customPrice or vehicleData.price or 500000
                    ExecuteQuery("INSERT INTO job_storage_cars (vehicle_name, plate, price, status) VALUES (?, ?, ?, 'stored')", {vehicleName, plate, priceToUse})
                    TriggerClientEvent('esx:showNotification', src, "Fahrzeug fertig: "..vehicleName.." (Plate: "..plate..")")

                    -- NUI Update für alle Spieler mit Job
                    TriggerClientEvent('autobauer:client:updateVehicleStorage', src, GetStorageCars())
                end)
            end)
        end)
    end)

    -- Fahrzeug an Autohaus
    RegisterNetEvent('autobauer:server:sendToDealership', function(carId)
        local src = source
        if not IsAllowedJob(src) then
            TriggerClientEvent('esx:showNotification', src, "Du hast keinen Zugriff auf diese Funktion!")
            return
        end

        ExecuteQuery("SELECT * FROM job_storage_cars WHERE id = ?", {carId}, function(result)
            if not result[1] then
                TriggerClientEvent('esx:showNotification', src, "Fahrzeug nicht gefunden!")
                return
            end
            local vehicle = result[1]
            ExecuteQuery("INSERT INTO car_stock (vehicle_name, plate, price, owner, sold) VALUES (?, ?, ?, 'dealership', 0)", {vehicle.vehicle_name, vehicle.plate, vehicle.price})
            ExecuteQuery("DELETE FROM job_storage_cars WHERE id = ?", {carId})
            TriggerClientEvent('esx:showNotification', src, "Fahrzeug erfolgreich an Autohaus übergeben!")

            TriggerClientEvent('autobauer:client:updateVehicleStorage', src, GetStorageCars())
        end)
    end)

    -- Alle Mitarbeiter
    ESX.RegisterServerCallback('autobauer:server:getEmployees', function(source, cb)
        if not IsAllowedJob(source) then cb({}) return end
        ExecuteQuery("SELECT * FROM job_employees", {}, cb)
    end)
end

-- =========================
-- QBCore Callbacks & Events (platzhalter)
-- =========================
function RegisterQBCoreCallbacksAndEvents()
    -- Analog zu ESX, QBCore Events & Callbacks hier registrieren
end

-- =========================
-- Hilfsfunktionen für NUI Updates
-- =========================
function GetStorageCars()
    local cars = {}
    ExecuteQuery("SELECT * FROM job_storage_cars", {}, function(result)
        cars = result
    end)
    return cars
end
