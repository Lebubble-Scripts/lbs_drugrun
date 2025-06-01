RegisterServerEvent("lbs_drugrun:server:rewardItems", function(drug, dcoords)
    local src = source
    local Player = getPlayer(src)
    print('server event triggered')
    local pcoords = GetEntityCoords(GetPlayerPed(src))
    print(pcoords)
    print(dcoords)

    if #(pcoords - dcoords) > 25.0 then 
        print(('Player %d is too far from the delivery coordinates.'):format(src))
        return
    end
    print('adding items')
    local drugRewardAmount = math.random(1, 3)
    addItem(src, drug, drugRewardAmount)

    for k, v in pairs(Config.MissionRewards) do
        addItem(src, k, v)
    end
end)