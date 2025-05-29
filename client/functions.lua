function CleanupMission()
    if truck then
        DeleteVehicle(truck)
        truck = nil
    end
    if pickupBlip then
        RemoveBlip(pickupBlip)
        pickupBlip = nil
    end
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    missionActive = false
    if boxObj then 
        DeleteEntity(boxObj)
        boxObj = nil
    end
    if palletObj then 
        DeleteEntity(palletObj)
        palletObj = nil
    end
    if IsEntityPlayingAnim(PlayerPedId(), carryingAnimDict, carryingAnimName) then
        ClearPedTasks(PlayerPedId())
    end
    if pickupBlip then 
        SetBlipRoute(pickupBlip, false)
        RemoveBlip(pickupBlip)
        pickupBlip = nil
    end
    if deliveryBlip then 
        RemoveBlip(deliveryBlip)
        SetBlipRoute(deliveryBlip, false)
        deliveryBlip = nil
    end
    
end


function getPlayer(source)
    if Config.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qbx' then 
        return qbx:GetPlayer(source)
    end
end


function SpawnPalletProp(propCoords)
    RequestModel(weedPallet)
    while not HasModelLoaded(weedPallet) do
        Wait(1)
    end

    palletObj = CreateObject(weedPallet, propCoords.x, propCoords.y, propCoords.z - 1, true, true, false)
    return palletObj
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

function VariableCleanup()
    hasArrivedAtPickup = false
    boxesPickedUp = 0
    boxesToPickUp = Config.MissionOptions.boxesToPickUp
end

function WeedNotify(description, type)
    if Config.Notify == 'ox' then
        lib.notify({
            title = "Weed Run",
            description = description,
            type = type or "info"
        })
    elseif Config.Notify == 'qb' then
        QBCore.Functions.Notify(description, type or "primary")
    end
end