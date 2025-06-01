function GetPlayer(source)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'qbx' then 
        return qbx:GetPlayer(source)
    end
end


function AddItem(source, item, amount)
    local src = source
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:AddItem(src, item, amount)
    elseif GetResourceState('qb-inventory') == 'started' then
        --stupid ass QB workaround since they can't do it in their inventory :)
        if item == 'cash' then 
            Player = GetPlayer(src)
            Player.Functions.AddMoney('cash', amount)
        else 
            exports['qb-inventory']:AddItem(src, item, amount)
        end
    end
    print(('Added %s x%d to player %d'):format(item, amount, src))
end

function ServerNotify(source, message, type)
    if Config.Notify == 'ox' then 
        TriggerClientEvent("ox_lib:notify", source, {
            title = 'Drug Runs',
            description = message,
            type = type,
            position = "center-left",
            iconAnimation = "beatFade",
            duration = 5000, 

        })
    elseif Config.Notify == 'qb' then 
        TriggerClientEvent('QBCore:Notify', source, message, type)
    end

end