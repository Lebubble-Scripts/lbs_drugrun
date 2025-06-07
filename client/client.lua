local function spawnPeds()
    local pedModel = "a_m_m_business_01"


    for k, v in pairs(Config.PedLocations) do 
        DebugPrint(('Spawning ped at location: %s'):format(tostring(v.loc)))    
        local ped = CreatePedModel(pedModel, v.loc, v.heading)
        exports.ox_target:addLocalEntity(ped, {
            {
                name = "startDrugrun",
                icon = "fa-solid fa-pills",
                label = "Start Drug Run",
                onSelect = function()
                    if missionActive then 
                        ClientNotify("A drug run is already in progress. Please complete the mission to accept a new one.", 'error')
                        return
                    end
                    local input = lib.inputDialog("Select Drug Type", {
                        {type='select', label='Drug Type', options=
                        Config.DrugOptions or {}
                        , default=1}
                    })
                    if input and input[1] then 
                        TriggerEvent("lbs_drugrun:client:startMission", input[1])
                    end
                end,
            }
        })

    end
end

spawnPeds()

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DebugPrint("Resource stopped, cleaning up mission.")
        CleanupMission()
    end
end)

RegisterCommand('cleanupMission', function()
    DebugPrint("Cleanup command executed.")
    CleanupMission()
end, false)