ORM:instantiateDBTables()

RegisterServerEvent("lbs_drugrun:server:rewardItems", function(drug, dcoords)
    local src = source
    local Player = GetPlayer(src)
    DebugPrint(('Attempting to reward items to %d for drug run.'):format(src))
    local pcoords = GetEntityCoords(GetPlayerPed(src))


    if #(pcoords - dcoords) > 25.0 then 
        print(('Player %d is too far from the delivery coordinates.'):format(src))
        return
    end
    local drugRewardAmount = math.random(1, Config.MaxDrugRewardAmount)
    AddItem(src, drug, drugRewardAmount)
    ServerNotify(src, ('You have received %d x %s as a reward for the drug run.'):format(drugRewardAmount, drug), 'success')
    DebugPrint(('Player %d has received %d x %s as a reward for the drug run.'):format(src, drugRewardAmount, drug))

    for k, v in pairs(Config.MissionRewards) do
        AddItem(src, k, v)
        ServerNotify(src, ('You have received %d x %s as a reward for the drug run.'):format(v, k), 'success')
        DebugPrint(('Player %d has received %d x %s as a reward for the drug run.'):format(src, v, k))
    end
end)

RegisterServerEvent("lbs_drugrun:server:rewardExp", function(drug)
    local identifier = GetIdentifier(source, 'license')

end)

RegisterCommand('checkIdent', function(source, args)
    print(getIdentifier(source, 'license') or 'No identifier found')
end, false)