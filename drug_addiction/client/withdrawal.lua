local withdrawalActive = false

RegisterNetEvent('drug_system:startWithdrawal', function()
    if withdrawalActive then return end
    withdrawalActive = true

    Citizen.CreateThread(function()
        local duration = Config.Withdrawal.duration

        while duration > 0 do
            Citizen.Wait(10000)
            duration = duration - 10

            for _, effect in pairs(Config.Withdrawal.effects) do
                if effect.type == "blur" then
                    SetTimecycleModifier("DRUG_gas_huffin")
                elseif effect.type == "shaking" then
                    ShakeGameplayCam("DRUNK_SHAKE", effect.intensity)
                elseif effect.type == "stamina_drain" then
                    RestorePlayerStamina(PlayerId(), -effect.amount)
                end
            end
        end

        withdrawalActive = false
        SetTimecycleModifier("default")
        StopGameplayCamShaking(true)
    end)
end)
