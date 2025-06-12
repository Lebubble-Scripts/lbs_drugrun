ORM:instantiateDBTables()

local function GetDrugDetails(drug)
    for k, v in pairs(Config.DrugOptions) do 
        print('Checkings values')
        print('K: ' .. k)
        print('Drug: ' .. drug)
        print('V.value: ' .. v.value)
        if v.value == drug then 
            return v.min_exp, v.max_exp, v.maxAmount 
        end
    end
    return nil, nil, nil
end


RegisterServerEvent("lbs_drugrun:server:missionReward", function(drug, dcoords)
    print('server event: lbs_drugrun:server:missionReward')
    print(drug)
    local src = source
    local Player = GetPlayer(src)
    local ident = GetIdentifier(src, 'license')
    local cid = GetCitizenID(src)
    if not ident or not cid then
        DebugPrint(('Player %d does not have a valid identifier or citizen ID.'):format(src))
        return
    end
    DebugPrint(('Attempting to reward items to %d for drug run.'):format(src))
    local pcoords = GetEntityCoords(GetPlayerPed(src))

    if #(pcoords - dcoords) > 25.0 then 
        DebugPrint(('Player %d is too far from the delivery coordinates.'):format(src))
        return
    end

    print("finding items")
    local minXP, maxXP, maxAmount = GetDrugDetails(drug)
    if not minXP or not maxXP or not maxAmount then
        ServerNotify(src, ('Invalid drug type: %s'):format(drug), 'error')
        return
    end

    local xp = math.random(minXP, maxXP)
    local amount = math.random(1, maxAmount)

    AddItem(src, drug, amount)
    ServerNotify(src, ('You have received %d x %s as a reward for the drug run.'):format(amount, drug), 'success')
    DebugPrint(('Player %d has received %d x %s as a reward for the drug run.'):format(src, amount, drug))

    for k, v in pairs(Config.MissionRewards) do
        AddItem(src, k, v)
        ServerNotify(src, ('You have received %d x %s as a reward for the drug run.'):format(v, k), 'success')
        DebugPrint(('Player %d has received %d x %s as a reward for the drug run.'):format(src, v, k))
    end

    ORM.AddXPAmount(ident, cid, xp)
end)


-- RegisterCommand('checkIdent', function(source, args)
--     print(getIdentifier(source, 'license') or 'No identifier found')
-- end, false)

-- RegisterCommand('addDrugXP', function(source, args)
--     local src = source
--     local ident = GetIdentifier(src, 'license')
--     local cid = GetCitizenID(src)
--     if not ident or not cid then
--         DebugPrint(('Player %d does not have a valid identifier or citizen ID.'):format(src))
--         return
--     end
--     local xpAmount = tonumber(args[1]) or 100 -- Default to 100 if no argument is provided
--     ORM.AddXPAmount(ident, cid, xpAmount)
--     ServerNotify(src, ('You have been awarded %d XP for drug runs.'):format(xpAmount), 'success')
-- end, false)