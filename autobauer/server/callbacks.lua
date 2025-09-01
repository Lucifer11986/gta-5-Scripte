-- DB Helper (oxmysql oder async)
function ExecuteQuery(query, params, cb)
    if Config.DBType == "oxmysql" then
        exports.oxmysql:execute(query, params, function(result)
            if cb then cb(result) end
        end)
    else -- async
        MySQL.Async.fetchAll(query, params, function(result)
            if cb then cb(result) end
        end)
    end
end
