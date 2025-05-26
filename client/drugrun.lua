local missionActive = false
local truck = nil
local pickupBlip = nil
local deliveryBlip = nil

local pickupCoords = vector3(2484.59, 3748.7, 42.79)
local deliveryCoords = vector3(1677.92, 3281.74, 40.83)

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
end

RegisterNetEvent('lbs_drugrun:client:startMission', function()
    if missionActive then 
        lib.notify({
            title = "Weed Run",
            description = "You are already on a mission.",
            type = "error"
        })
        return
    end

    missionActive = true

    -- Request model and ensure it's loaded
    local vehicleHash = GetHashKey('mule')
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(1)
        print('waiting for model to load', vehicleHash)
    end

    -- Spawn the truck at the pickup location
    truck = CreateVehicle(vehicleHash, pickupCoords.x, pickupCoords.y, pickupCoords.z, true, false)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', GetVehicleNumberPlateText(truck))
    SetEntityAsMissionEntity(truck, true, true)
    SetVehicleDoorsLocked(truck, 1)

    -- Add a blip for the pickup location
    pickupBlip = AddBlipForCoord(pickupCoords)
    SetBlipSprite(pickupBlip, 477)
    SetBlipColour(pickupBlip, 2)
    SetBlipScale(pickupBlip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Weed Run Pickup")
    EndTextCommandSetBlipName(pickupBlip)

    lib.notify({
        title = "Weed Run",
        description = "Go to the pickup location and load the truck.",
        type = "info"
    })

end)

CreateThread(function()
    while true do 
        Wait(0)
        print('checking mission status')
        if not missionActive then Wait(500) goto continue end 
        print('mission is active, checking for truck and blips')
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        if pickupBlip and #(pcoords - pickupCoords) < 5.0 and IsPedInVehicle(ped, truck, false) then 
            print('ped is in vehicle and near pickup coords')
            RemoveBlip(pickupBlip)
            pickupBlip = nil

            deliveryBlip = AddBlipForCoord(deliveryCoords)
            SetBlipSprite(deliveryBlip, 478)
            SetBlipColour(deliveryBlip, 5)
            SetBlipScale(deliveryBlip, 0.8)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Weed Run Delivery")
            EndTextCommandSetBlipName(deliveryBlip)
            lib.notify({
                title = "Weed Run",
                description = "Deliver the truck to the destination.",
                type = "info"
            })
        end

        if deliveryBlip and IsPedInVehicle(ped, truck, false) and #(pcoords - deliveryCoords) < 5.0 then 
            RemoveBlip(deliveryBlip)
            deliveryBlip = nil
            lib.notify({
                title = "Weed Run",
                description = "Mission completed! You delivered the weed.",
                type = "success"
            })
            DeleteVehicle(truck)
            truck = nil
            missionActive = false
        end
        ::continue::
    end
end)

