RegisterServerEvent("lbs_drugrun:server:rewardItems", function(drug, dcoords)
    local src = source
    local Player = GetPlayer(src)
    print('server event triggered')
    local pcoords = GetEntityCoords(GetPlayerPed(src))
    print(pcoords)
    print(dcoords)

    if #(pcoords - dcoords) > 25.0 then 
        print(('Player %d is too far from the delivery coordinates.'):format(src))
        return
    end
    local drugRewardAmount = math.random(1, Config.MaxDrugRewardAmount)
    AddItem(src, drug, drugRewardAmount)
    ServerNotify(src, ('You have received %d x %s as a reward for the drug run.'):format(drugRewardAmount, drug), 'success')

    for k, v in pairs(Config.MissionRewards) do
        AddItem(src, k, v)
        ServerNotify(src, ('You have received %d x %s as a reward for the drug run.'):format(v, k), 'success')
    end
end)