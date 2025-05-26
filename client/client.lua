local function spawnPeds()
    local pedModel = "a_m_m_business_01" -- Replace with the desired ped model
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end
    --vector4(2486.95, 3726.88, 43.92, 37.01)
    ped = CreatePed(4, pedModel, 2486.95, 3726.88, 43.92-1, 37.01, true, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(pedModel)
    
    exports.ox_target:addLocalEntity(ped, {
        {
            name = "startDrugrun",
            icon = "fa-solid fa-cannabis",
            label = "Start Weed Run",
            onSelect = function()
                TriggerEvent("lbs_drugrun:client:startMission")
            end,
        }
    })
end

spawnPeds()


RegisterCommand('pickupbox', function()
    StartCarryingBox()
end)

RegisterCommand('dropbox', function()
    StopCarryingBox()
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

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupBox()
        CleanupMission()
    end
end)

RegisterCommand('spawnMule', function()
    print('attempting to spawn mule')
    local vehicleHash = GetHashKey('mule')
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(1)
        print('waiting for model to load', vehicleHash)
    end
    
    
    local pcoords = GetEntityCoords(PlayerPedId())
    print('spawning ' .. ' ' .. vehicleHash .. ' at', pcoords)

    local truck = CreateVehicle(vehicleHash, pcoords.x + 10, pcoords.y, pcoords.z + 1, true, false)
    SetEntityAsMissionEntity(truck, true, true)
    SetVehicleDoorsLocked(truck, 1)
end)