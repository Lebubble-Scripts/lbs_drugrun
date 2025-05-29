Config = {}


Config.Notify = 'ox'        -- 'ox', 'qb'
Config.Framework = 'qb'     -- 'qbx', 'qb',


if Config.Framework == 'qb' then
    print('[FRAMEWORK] ^5Deteced QBCore Framework^7')
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Set the cooldown time in seconds
-- 60 * 5 = 300 seconds = 5 minutes
-- 60 * 60 * 2 = 7200 seconds = 2 hours
Config.Cooldown = 10

-- Set different run locations here, for now we only do weed run
---@param pickupCoords vector3 : the location where the truck will spawn for pickup
---@param deliveryCoords vector3 : the location where the truck will deliver the weed boxes
---@param propCoords vector3 : the location where the weed pallet will spawn
Config.Locations = {
    {
        pickupCoords = vector3(1983.02, 3777.55, 32.18),
        deliveryCoords = vector3(1677.92, 3281.74, 40.83),
        propCoords = vector3(1974.14, 3766.81, 32.19),
    },
    --below is an example of how to add another run location
    --the script will randomly select one of the locations from the list
    --{
    --    pickupCoords = vector3(2486.95, 3726.88, 43.92),
    --    deliveryCoords = vector3(1677.92, 3281.74, 40.83),
    --    propCoords = vector3(2486.95, 3726.88, 43.92),
    --},
}

Config.MissionOptions = {
    boxesToPickUp = 1, -- Number of boxes to pick up
    truckModel = 'mule', -- Truck model to spawn
    weedPallet = 'hei_prop_heist_weed_pallet', -- Prop model for the weed pallet https://gtahash.ru/
}

Config.MissionRewards = {
    cash = 500, -- Money reward for completing the mission
    water_bottle = 1, 
}