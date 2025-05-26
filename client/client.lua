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

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupBox()
        CleanupMission()
    end
end)