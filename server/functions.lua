function getPlayer(source)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'qbx' then 
        return qbx:GetPlayer(source)
    end
end
