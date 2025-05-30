function getPlayer(source)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'qbx' then 
        return qbx:GetPlayer(source)
    end
end


function addItem(source, item, amount)
    local src = source
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:AddItem(src, item, amount)
    elseif GetResourceState('qb-inventory') == 'started' then
        if item == 'cash' then 
            Player = getPlayer(src)
            Player.Functions.AddMoney('cash', amount)
        exports['qb-inventory']:AddItem(src, item, amount)
    end
    ServerNotify(('Added %s x%d to player %d'):format(item, amount, src), 'success')
end