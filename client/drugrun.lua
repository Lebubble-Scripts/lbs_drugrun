local loc = {}
local randomIndex = nil 


RegisterNetEvent('lbs_drugrun:client:startMission', function(drug)
    --randomly choose a location
    randomIndex = math.random(1, #Config.Locations)
    loc = Config.Locations[randomIndex]
    DebugPrint("Selected location index: " .. randomIndex)
    DebugPrint("Selected location: " .. json.encode(loc))

    if drug then 
        drugType = drug
        DebugPrint("Starting mission for drug type: " .. drugType)
    else
        DebugPrint("No Drug Type Provided")
        return
    end

    if missionActive then 
        DebugPrint("Mission is already active, cannot start a new one.")
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
    DebugPrint("Spawning truck at pickup location: " .. json.encode(loc.pickupCoords))
    truck = CreateVehicle(vehicleHash, loc.pickupCoords.x, loc.pickupCoords.y, loc.pickupCoords.z, true, false)
    GiveVehicle(truck)

    -- Add a blip for the pickup location
    pickupBlip = CreateBlip(loc.pickupCoords, 477, 2, 0.8, "Drug Run Pickup")
    DebugPrint("Created pickup blip at: " .. json.encode(loc.pickupCoords))

    ClientNotify("Mission started! Go to the pickup location and load the truck with drugs!", 'info')

    -- Spawn the pickup box 
    local palletObj = SpawnPalletProp(loc.propCoords)
    DebugPrint("Spawned pallet object at: " .. json.encode(loc.propCoords))

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
    DebugPrint("Added target interaction for pallet object.")
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
        end
        -- add check to ensure boxes are loaded into truck 
        if pickupBlip then 
            local dist = #(pcoords - loc.pickupCoords)
            if dist < 20.0 and not hasArrivedAtPickup then
                hasArrivedAtPickup = true
                DebugPrint("Player has arrived at pickup location.")
                ClientNotify("You have arrived at the pickup location. Load the truck with boxes.", 'info')
            end
            if IsCarryingBox() and truck  then 
                local truckCoords = GetEntityCoords(truck)
                local dist = #(GetEntityCoords(PlayerPedId()) - truckCoords)

                if dist < 3.0 then 
                    lib.showTextUI("[E] Load box into truck")
                    if IsControlJustPressed(0, 38) then
                        DebugPrint("Box loaded into truck.")
                        StopCarryingBox()
                        boxesPickedUp = boxesPickedUp + 1
                        ClientNotify(("Box loaded into truck! [%d/%d]"):format(boxesPickedUp, boxesToPickUp), 'success')
                        if boxesPickedUp >= boxesToPickUp then
                            DebugPrint("All boxes loaded into truck.")
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
                DebugPrint("Leaving pickup, removing pickup blip and creating delivery blip.")
                RemoveBlip(pickupBlip)
                SetBlipRoute(pickupBlip, false)
                pickupBlip = nil

                deliveryBlip = CreateBlip(loc.deliveryCoords, 478, 5, 0.8, drugType .. " Delivery")
                ClientNotify("Deliver the truck to the delivery location.", 'info')
            end
        end
        
        if deliveryBlip then 
            local dist = #(pcoords - loc.deliveryCoords) 
            local deliveryPed = nil
            if deliveryPed and deliveryPedSpawned then
                DebugPrint("Delivery ped already spawned, checking distance.")
            elseif not delieveryPed and not deliveryPedSpawned then 
                local deliveryPed = CreatePedModel("a_m_m_business_01", loc.deliveryPed.coords, loc.deliveryPed.heading)
                deliveryPedSpawned = true 
            end
            if dist < 25.0 then
                local boxesToDeliver = boxesToPickUp
                local boxesDelievered = 0
                
                if IsPedInVehicle(ped, truck, true) and not deliveryStarted then 
                    deliveryStarted = true
                    DebugPrint("Delivery started, player is in vehicle.")
                    ClientNotify("You have arrived at the delivery location. Deliver the boxes to complete the mission.", 'info')
                    exports['ox_target']:addLocalEntity(truck, {
                        {
                            title = "Collect Box",
                            icon = "fa-solid fa-box",
                            label = "Collect Box from Truck",
                            onSelect = function()
                                if not missionActive then return end
                                if boxesDelievered >= boxesToDeliver then
                                    ClientNotify("You have already delivered all the boxes.", 'error')
                                    return
                                elseif not IsCarryingBox() then
                                    StartCarryingBox()
                                    ClientNotify("You have collected a box from the truck. Deliver it to the destination.", 'info')
                                else
                                    ClientNotify("You are already carrying a box.", 'error')
                                end
                            end
                        }
                    })
                end
                if IsCarryingBox() and not IsPedInVehicle(ped, truck, true) and deliveryStarted then
                    local dist = #(pcoords - loc.deliveryPed.coords)
                    if dist < 3.0 then
                        lib.showTextUI("[E] Deliver Box")
                        if IsControlJustPressed(0, 38) then
                            DebugPrint("Box delivered to delivery location.")
                            StopCarryingBox()
                            boxesDelievered = boxesDelievered + 1
                            ClientNotify(("Box delivered! [%d/%d]"):format(boxesDelievered, boxesToDeliver), 'success')
                            if boxesDelievered >= boxesToDeliver then
                                DebugPrint("All boxes delivered, mission complete.")
                                ClientNotify("You have delivered all the boxes. Mission complete!", 'success')
                                RemoveBlip(deliveryBlip)
                                TriggerServerEvent('lbs_drugrun:server:rewardItems', drugType, loc.deliveryCoords)
                                CleanupMission()
                                lib.hideTextUI()
                                return
                            end
                        end
                    else
                        lib.hideTextUI()
                    end
                else
                    lib.hideTextUI()
                end
            end
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

RegisterCommand('quitMission', function()
    if not missionActive then 
        ClientNotify("You are not on a mission.", 'error')
        return
    end
    missionActive = false
    VariableCleanup()
    CleanupMission()
    ClientNotify("You have quit the mission.", 'success')
end, false)