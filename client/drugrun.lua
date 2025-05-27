local randomIndex = math.random(1, #Config.Locations)
local loc = Config.Locations[randomIndex]


RegisterNetEvent('lbs_drugrun:client:startMission', function()
    if missionActive then 
        lib.notify({
            title = "Weed Run",
            description = "You are already on a mission.",
            type = "error"
        })
        return
    end

    --ensure varaibles are reset, TODO: move to a function
    missionActive = true
    hasArrivedAtPickup = false
    boxesPickedUp = 0
    boxesToPickUp = 1

    -- Request model and ensure it's loaded
    local vehicleHash = GetHashKey('mule')
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(1)
    end

    -- Spawn the truck at the pickup location
    truck = CreateVehicle(vehicleHash, loc.pickupCoords.x, loc.pickupCoords.y, loc.pickupCoords.z, true, false)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', GetVehicleNumberPlateText(truck))
    SetEntityAsMissionEntity(truck, true, true)
    SetVehicleDoorsLocked(truck, 1)

    -- Add a blip for the pickup location
    pickupBlip = AddBlipForCoord(loc.pickupCoords)
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
    print("Spawning pallet at: ", loc.propCoords)
    local palletObj = SpawnPalletProp(loc.propCoords)

    exports.ox_target:addLocalEntity(palletObj, {
        {
            name = "pickupBox",
            icon = "fa-solid fa-box",
            label = "Load Weed Box",
            onSelect = function()
                if IsCarryingBox() then
                    lib.notify({
                        title = "Weed Run",
                        description = "You are already carrying a box.",
                        type = "error"
                    })
                    return
                end
                print('missionActive: ', missionActive)
                if not missionActive then return end 
                if boxesPickedUp < boxesToPickUp then
                    StartCarryingBox()
                    lib.notify({
                        title = "Weed Run",
                        description = ("Box picked up! Load it into the truck!"):format(boxesPickedUp, boxesToPickUp),
                        type = "success"
                    })
                elseif boxesPickedUp >= boxesToPickUp then
                    lib.notify({
                        title = "Weed Run",
                        description = "You have already picked up all the boxes.",
                        type = "error"
                    })
                    return
                end

            end,
        }
    })

end)

CreateThread(function()
    while true do 
        Wait(0)
        if not missionActive then Wait(500) goto continue end 
        local ped = PlayerPedId()
        local pcoords = GetEntityCoords(ped)

        -- add check to ensure boxes are loaded into truck 
        if pickupBlip then 
            local dist = #(pcoords - loc.pickupCoords)
            if dist < 20.0 and not hasArrivedAtPickup then
                hasArrivedAtPickup = true
                lib.notify({
                    title = "Weed Run",
                    description = "You have arrived at the pickup location. Load the truck with weed boxes.",
                    type = "info"
                })
            end
            
            if IsCarryingBox() and truck  then 
                local truckCoords = GetEntityCoords(truck)
                local dist = #(GetEntityCoords(PlayerPedId()) - truckCoords)

                if dist < 3.0 then 
                    lib.showTextUI("[E] Load box into truck")
                    if IsControlJustPressed(0, 38) then
                        StopCarryingBox()
                        boxesPickedUp = boxesPickedUp + 1
                        lib.notify({
                            title = "Weed Run",
                            description = ("Box loaded into truck! [%d/%d]"):format(boxesPickedUp, boxesToPickUp),
                            type = "success"
                        })
                        if boxesPickedUp >= boxesToPickUp then
                            lib.notify({
                                title = "Weed Run",
                                description = "You have loaded all the boxes. Get in the truck and deliver to the destination.",
                                type = "success"
                            })
                        end
                    end
                else
                    lib.hideTextUI()
                end
            else
                lib.hideTextUI()
            end

            if hasArrivedAtPickup and boxesPickedUp >= boxesToPickUp and IsPedInVehicle(ped, truck, true) then
                RemoveBlip(pickupBlip)
                pickupBlip = nil

                deliveryBlip = AddBlipForCoord(loc.deliveryCoords)
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

        if deliveryBlip and IsPedInVehicle(ped, truck, false) and #(pcoords - loc.deliveryCoords) < 5.0 then 
            RemoveBlip(deliveryBlip)
            deliveryBlip = nil
            lib.notify({
                title = "Weed Run",
                description = "Mission completed! You delivered the weed.",
                type = "success"
            })
            -- TODOLT = to do long term
            -- TODOLT replace below with freezing truck and having the player "deliver" the boxes to a ped. Once done a reward is given
            -- TODO check if player is out of vehicle before deleting the truck
            -- TODO add reward for completing the mission -> setup rewards in config.lua
            DeleteVehicle(truck) 
            truck = nil
            missionActive = false
            CleanupMission()
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
            EnableControlAction(0, 24, true) -- Disable LMB attack
            EnableControlAction(0, 25, true) -- Disable RMB aim
            EnableControlAction(0, 22, true)
        end
        Wait(0)
    end
end)
