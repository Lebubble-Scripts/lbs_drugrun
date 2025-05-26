local missionActive = false
local truck = nil
local pickupBlip = nil
local deliveryBlip = nil
local hasArrivedAtPickup = false

local pickupCoords = vector3(1983.02, 3777.55, 32.18)
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
    hasArrivedAtPickup = false

    -- Request model and ensure it's loaded
    local vehicleHash = GetHashKey('mule')
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(1)
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

    -- Spawn the pickup box 

    -- Move box(es) to the truck 

    -- ensure boxes are loaded

end)

CreateThread(function()
    while true do 
        Wait(0)
        if not missionActive then Wait(500) goto continue end 
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        -- add check to ensure boxes are loaded into truck 
        if pickupBlip then 
            local dist = #(pcoords - pickupCoords)
            if dist < 5.0 and not hasArrivedAtPickup then
                hasArrivedAtPickup = true
                lib.notify({
                    title = "Weed Run",
                    description = "You have arrived at the pickup location. Load the truck with weed boxes.",
                    type = "info"
                })
            end

            if hasArrivedAtPickup and IsPedInVehicle(ped, truck, false) then
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
        end

        if deliveryBlip and IsPedInVehicle(ped, truck, false) and #(pcoords - deliveryCoords) < 5.0 then 
            RemoveBlip(deliveryBlip)
            deliveryBlip = nil
            lib.notify({
                title = "Weed Run",
                description = "Mission completed! You delivered the weed.",
                type = "success"
            })
            -- replace below with freezing truck and having the player "deliver" the boxes to a ped. Once done a reward is given
            DeleteVehicle(truck) 
            truck = nil
            missionActive = false
        end
        ::continue::
    end
end)


CreateThread(function()
    while true do 
        if IsCarryingBox() then 
            EnsureCarryAnim()

            DisableControlAction(0, 24, true) -- Disable LMB attack
            DisableControlAction(0, 25, true) -- Disable RMB aim
            DisableControlAction(0, 22, true)
        else
            Wait(500)
        end
        Wait(0)
    end
end)
