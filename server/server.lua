local cooldowns = {}

RegisterServerEvent('lbs_drugrun:server:startRun', function()
    local src = source
    local Player = getPlayer(src)

    if cooldowns[src] and cooldowns[src] > os.time() then 
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'You are on cooldown for this event.',
            type = 'error'
        })
        return
    end

    cooldowns[src] = os.time() + Config.Cooldown
end)