function CleanupMission()
    DebugPrint("Attempting to clean up mission resources.")
    --Remove ox target entities
    exports.ox_target:removeLocalEntity(palletObj)
    exports.ox_target:removeLocalEntity(delieveryPed)

    --Remove active entities, blips, and peds
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
    if delieveryPed then 
        DeletePed(delieveryPed)
    end
    VariableCleanup()
    DebugPrint("Mission resources cleaned up successfully.")
end

function SpawnPalletProp(propCoords)
    local pallet = "v_ind_cf_boxes"
    RequestModel(pallet)
    while not HasModelLoaded(pallet) do
        Wait(1)
    end

    palletObj = CreateObject(pallet, propCoords.x, propCoords.y, propCoords.z - 1, true, true, false)
    FreezeEntityPosition(palletObj, true)
    return palletObj
end

function IsCarryingBox()
    return boxObj ~= nil 
end

function StartCarryingBox()
    if IsCarryingBox() then
        lib.notify({
            title = "Drug Run",
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
            title = "Drug Run",
            description = "You are not carrying a box.",
            type = "error"
        })
        return
    end

    ClearPedTasks(PlayerPedId())
    DeleteEntity(boxObj)
    boxObj = nil
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
    missionActive = false
    truck = nil
    pickupBlip = nil
    deliveryBlip = nil
    hasArrivedAtPickup = false
    notifiedDelivery = false
    boxesPickedUp = 0
    boxesToPickUp = 1
    drugType = nil
    palletObj = nil
    cooldownTime = nil
    deliveryStarted = false
    delieveryPed = nil
end

function ClientNotify(description, type)
    if Config.Notify == 'ox' then
        lib.notify({
            title = "Drug Run",
            description = description,
            type = type or "info",
            position = "center-left",
            iconAnimation = "beatFade",
            duration = 5000, 

        })
    elseif Config.Notify == 'qb' then
        QBCore.Functions.Notify(description, type or "primary")
    end
end

function GetLabel(item)
    if GetResourceState('ox_inventory') == 'started' then
        local Items = exports.ox_inventory:Items()
        if Items[item] then 
            return Items[item].label
        end
    elseif GetResourceState('qb-inventory') == 'started' then
        if QBCore.Shared.Items[item] then 
            return QBCore.Shared.Items[item].label
        end
    else 
        return 'Item not found'
    end
end


function CreateBlip(coords, sprite, color, scale, name)
    print(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    SetBlipRoute(blip, true)
    SetBlipColour(blip, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

function CreateCircleMarker(coords)
    DrawMarker(
        1,
        coords.x, coords.y, coords.z - 1,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        5.0, 5.0, 1.5,
        255, 255, 0, 100,
        false, true, 2, false, nil, nil, false
    )
end

function CreatePedModel(model, coords, heading)
    local pedModel = model 
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end
    local ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1, heading, true, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(pedModel)
    return ped
end

function GiveVehicle(vehicle)
    if GetResourceState('qb-core') == 'started' then 
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", GetVehicleNumberPlateText(vehicle))
        TriggerEvent('LegacyFuel:client:SetFuel', vehicle, 100.0) -- Set fuel to full
        DebugPrint("Acquired vehicle keys for truck with plate: " .. GetVehicleNumberPlateText(vehicle))
        SetEntityAsMissionEntity(truck, true, true)
        SetVehicleDoorsLocked(truck, 1)
    end
end