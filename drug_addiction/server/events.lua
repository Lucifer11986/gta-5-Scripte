RegisterCommand('startEvent', function(source, args, rawCommand)
    if args[1] == "drugfree" then
        TriggerClientEvent('drug_system:startDrugFreeEvent', -1)
    end
end, true)
