local boxObj = nil
local carryingAnimDict = 'anim@heists@box_carry@';
local carryingAnimName = 'idle';
local boxModel = 'hei_prop_heist_box';

function getPlayer(source)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbx' then 
        return qbx:GetPlayer(source)
    end
end


function IsCarryingBox()
    return boxObj ~= nil 
end

function StartCarryingBox()
    if IsCarryingBox() then
        lib.notify({
            title = "Weed Run",
            description = "You are already carrying a box.",
            type = "error"
        })
        return
    end

    local ped = PlayerPedId()
    RequestModel(boxModel)
    while not HasModelLoaded(boxModel) do
        Wait(1)
    end

    boxObj = CreateObject(boxModel, GetEntityCoords(ped), 0, 0, true, true, false)
    AttachEntityToEntity(boxObj, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, -0.2, 0.0, 0.0, 0.0, false, false, false, true, 1, true)

    RequestAnimDict(carryingAnimDict)
    while not HasAnimDictLoaded(carryingAnimDict) do
        Wait(1)
    end
    TaskPlayAnim(ped, carryingAnimDict, carryingAnimName, 8.0, -8.0, -1, 49, 0, false, false, false)
end

function StopCarryingBox()
    if not IsCarryingBox() then 
        lib.notify({
            title = "Weed Run",
            description = "You are not carrying a box.",
            type = "error"
        })
        return
    end

    ClearPedTasks(PlayerPedId())
    DeleteEntity(boxObj)
    boxObj = nil
end

function CleanupBox()
    if boxObj then 
        DeleteEntity(boxObj)
    end
end

function EnsureCarryAnim()
    if IsCarryingBox() and not IsEntityPlayingAnim(PlayerPedId(), carryingAnimDict, carryingAnimName, 3) then
        if HasAnimDictLoaded(carryingAnimDict) then
            TaskPlayAnim(PlayerPedId(), carryingAnimDict, carryingAnimName, 8.0, -8.0, -1, 49, 0, false, false, false)
        else
            RequestAnimDict(carryingAnimDict)
            while not HasAnimDictLoaded(carryingAnimDict) do
                Wait(1)
            end
            TaskPlayAnim(PlayerPedId(), carryingAnimDict, carryingAnimName, 8.0, -8.0, -1, 49, 0, false, false, false)
        end
    end
end