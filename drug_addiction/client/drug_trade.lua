RegisterCommand('selldrug', function(source, args)
    local targetId = tonumber(args[1])
    local drug = args[2]
    local amount = tonumber(args[3])
    local price = tonumber(args[4])

    if targetId and drug and amount and price then
        TriggerServerEvent('drug_system:sellDrug', targetId, drug, amount, price)
    else
        print('Benutzung: /selldrug [Spieler-ID] [Droge] [Menge] [Preis]')
    end
end, false)
