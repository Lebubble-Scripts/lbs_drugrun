local loc = {}
local randomIndex = nil 


RegisterNetEvent('lbs_drugrun:client:startMission', function(drug)
    --randomly choose a location
    randomIndex = math.random(1, #Config.Locations)
    loc = Config.Locations[randomIndex]

    --os.time doesn't work on my server, so I commented out the cooldown logic
    -- if cooldownTime and cooldownTime < os.time() + Config.Cooldown then 
    --     ClientNotify("You are on a cooldown. Please wait before starting a new mission.", 'error')
    --     print("Cooldown time until next mission: " .. cooldownTime)
    --     return 
    -- else
    --     cooldownTime = os.time() + Config.Cooldown
    -- end

    if drug then 
        drugType = drug
    else
        return
    end

    if missionActive then 
        ClientNotify("You are already on a mission.", 'error')
        return
    end
    
    missionActive = true
    ClientNotify("Starting " .. GetLabel(drugType) .. ' run mission!', 'info')

    -- Request model and ensure it's loaded
    local vehicleHash = GetHashKey(Config.MissionOptions.truckModel)
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
    SetBlipRoute(pickupBlip, true)
    SetBlipRouteColour(pickupBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Drug Run Pickup")
    EndTextCommandSetBlipName(pickupBlip)

    ClientNotify("Mission started! Go to the pickup location and load the truck with drugs!", 'info')

    -- Spawn the pickup box 
    local palletObj = SpawnPalletProp(loc.propCoords)

    --add ox_target interaction for the pallet
    exports.ox_target:addLocalEntity(palletObj, {
        {
            name = "pickupBox",
            icon = "fa-solid fa-box",
            label = "Collect Drugs",
            onSelect = function()
                if IsCarryingBox() then
                    ClientNotify("You are already carrying a box.", 'error')
                    return
                end
                if not missionActive then return end 
                if boxesPickedUp < boxesToPickUp then
                    StartCarryingBox()
                    ClientNotify("Load the box into the truck.", 'info')
                elseif boxesPickedUp >= boxesToPickUp then
                    ClientNotify("You have already picked up all the boxes.", 'error')
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
        local notified = false

        --show where truck can be delivered
        if deliveryBlip and missionActive then
            CreateCircleMarker(loc.deliveryCoords)
            -- DrawMarker(
            --     1,
            --     loc.deliveryCoords.x, loc.deliveryCoords.y, loc.deliveryCoords.z - 1,
            --     0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            --     5.0, 5.0, 1.5,
            --     255, 255, 0, 100,
            --     false, true, 2, false, nil, nil, false
            -- )
        end
        -- add check to ensure boxes are loaded into truck 
        if pickupBlip then 
            local dist = #(pcoords - loc.pickupCoords)
            if dist < 20.0 and not hasArrivedAtPickup then
                hasArrivedAtPickup = true
                ClientNotify("You have arrived at the pickup location. Load the truck with boxes.", 'info')
            end
            if IsCarryingBox() and truck  then 
                local truckCoords = GetEntityCoords(truck)
                local dist = #(GetEntityCoords(PlayerPedId()) - truckCoords)

                if dist < 3.0 then 
                    lib.showTextUI("[E] Load box into truck")
                    if IsControlJustPressed(0, 38) then
                        StopCarryingBox()
                        boxesPickedUp = boxesPickedUp + 1
                        ClientNotify(("Box loaded into truck! [%d/%d]"):format(boxesPickedUp, boxesToPickUp), 'success')
                        if boxesPickedUp >= boxesToPickUp then
                            ClientNotify("You have loaded all the boxes into the truck. Deliver it to the destination.", 'success')
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
                SetBlipRoute(pickupBlip, false)
                pickupBlip = nil

                deliveryBlip = CreateBlip(loc.deliveryCoords, 478, 5, 0.8, drugType .. " Delivery")
                ClientNotify("Deliver the truck to the delivery location.", 'info')
            end
        end
        if deliveryBlip and #(pcoords - loc.deliveryCoords) < 5.0 then
            if not notifiedDelivery and IsPedInVehicle(ped, truck, true) then
                notifiedDelivery = true
                ClientNotify("You have arrived at the delivery location. Exit the truck to complete the mission.", 'info')
            elseif notifiedDelivery and not IsPedInVehicle(ped, truck, true) and #(pcoords - loc.deliveryCoords) < 5.0 then
                ClientNotify("Mission complete! You have delivered the truck.", 'success')
                RemoveBlip(deliveryBlip)
                TriggerServerEvent('lbs_drugrun:server:rewardItems', drugType, loc.deliveryCoords)
                CleanupMission()
            end
        elseif notifiedDelivery and (#(pcoords - loc.deliveryCoords) > 5.0) then
            notifiedDelivery = false
        end
        ::continue::
    end
end)


CreateThread(function()
    while true do 
        if IsCarryingBox() then 
            EnsureCarryAnim()

            DisableControlAction(0, 24, true) 
            DisableControlAction(0, 25, true) 
            DisableControlAction(0, 22, true)
        else
            Wait(500)
            EnableControlAction(0, 24, true)
            EnableControlAction(0, 25, true)
            EnableControlAction(0, 22, true)
        end
        Wait(0)
    end
end)


RegisterCommand('quitmission', function()
    if not missionActive then 
        ClientNotify("You are not on a mission.", 'error')
        return
    end
    missionActive = false
    VariableCleanup()
    CleanupMission()
    ClientNotify("You have quit the mission.", 'success')
end, false)