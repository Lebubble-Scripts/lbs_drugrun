RegisterServerEvent("lbs_drugrun:server:rewardItems", function()
    local src = source
    local Player = getPlayer(src)
    print('server event triggered')

    -- TODO, roll missing check into function and replace below
    -- if not missionActive then 
    --     print('Mission not active, cannot reward items.')
    --     return 
    -- end

    for k, v in pairs(Config.MissionRewards) do
        print(('Adding %s x%d to player %d'):format(k, v, src))
        addItem(src, k, v)
    end
end)