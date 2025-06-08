local items = Config.MissionRewards



function GetPlayer(source)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'qbx' then 
        return qbx:GetPlayer(source)
    elseif Config.Framework == 'esx' then 
        return ESX.GetExtendedPlayers()
    end
end

-- Functions for verifying items, distance, and amount
local function checkDist(src)
    local pcoord = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(Config.Locations) do
        if #(pcoord - v['deliveryCoords']) < 25.0 then
            return true
        end
    end
    return false
end

local function verifyItemsAmount(src, item, amount)
    for k, v in pairs(items) do
        if k == item then 
            if v == amount then 
                return true 
            else 
                print("hehe, you're bad")
            end
        else 
            print('Invalid item.')
        end
    end
    return false 
end



function AddItem(source, item, amount)
    local src = source
    DebugPrint("verifying item: " .. item .. " with amount: " .. amount)
    if not checkDist(src) then 
        DebugPrint(('Player %d is not at the delivery location.'):format(src))
        return
    end
    if not verifyItemsAmount(src, item, amount) then 
        DebugPrint(('Invalid amount for item %s: %d'):format(item, amount))
        return
    end
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
    DebugPrint(('Added %s x%d to player %d'):format(item, amount, src))
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
    elseif Config.Notify == 'esx' then 
        TriggerClientEvent('esx:showNotification', source, message, 5000, 'Drug Run')
    end
end
