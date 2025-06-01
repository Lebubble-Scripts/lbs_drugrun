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
            icon = "fa-solid fa-pills",
            label = "Start Drug Run",
            onSelect = function()
                local input = lib.inputDialog("Select Drug Type", {
                    {type='select', label='Drug Type', options=
                    {
                        {label='Weed', value='weed_brick'},
                        {label='Cocaine', value='cocaine'},
                        {label='Meth', value='meth'},
                        {label='Opium', value='opium'},
                    }
                    , default=1}
                })
                if input and input[1] then 
                    TriggerEvent("lbs_drugrun:client:startMission", input[1])
                end
            end,
        }
    })
end

spawnPeds()

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupMission()
    end
end)