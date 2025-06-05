Config = {}


Config.Notify = 'ox'                                -- 'ox', 'qb'
Config.Framework = 'qb'                             -- 'qb',
Config.Inventory = 'qb'                             -- 'qb', 'ox'

Config.EnableDebug = true

-- Set the cooldown time in seconds
-- 60 * 5 = 300 seconds = 5 minutes
-- 60 * 60 * 2 = 7200 seconds = 2 hours
Config.Cooldown = 60

Config.PedLocations = {
    {loc = vector3(2486.95, 3726.88, 43.92), heading = 37.01},
    {loc = vector3(1394.44,1141.72,114.61), heading = 88.73},
    {loc = vector3(-68.59,6255.08,31.09), heading = 120.41}
}

-- Set different run locations here, for now we only do weed run
---@param pickupCoords vector3 : the location where the truck will spawn for pickup
---@param deliveryCoords vector3 : the location where the truck will deliver the weed boxes
---@param propCoords vector3 : the location where the weed pallet will spawn
Config.Locations = {
    {
        pickupCoords = vector3(1983.02, 3777.55, 32.18),
        propCoords = vector3(1974.14, 3766.81, 32.19),
        deliveryCoords = vector3(1677.92, 3281.74, 40.83),
        deliveryPed = {coords = vector3(1680.73,3286.71,41.07), heading = 126.60}
    },
    {
        pickupCoords = vector3(1729.01,3320.06,41.22),
        propCoords = vector3(1737.52,3324.18,41.22),
        deliveryCoords = vector3(1882.86,2728.58,45.83),
        deliveryPed = {coords = vector3(1880.71, 2727.55, 45.83), heading = 284.17}
    },
    {
        pickupCoords = vector3(450.28,3564.29,33.24),
        propCoords = vector3(448.15,3552.93,33.24),
        deliveryCoords = vector3(1532.12, 1703.00, 109.75),
        deliveryPed = {coords = vector3(1537.34,1701.65,109.67), heading = 84.92}
    },
    {
        pickupCoords = vector3(737.06,1284.77,360.30),
        propCoords = vector3(747.30,1293.51,360.30),
        deliveryCoords = vector3(56.53, 3718.05,39.75),
        deliveryPed = {coords = vector3(63.65, 3714.76, 39.75), heading = 51.46}
    },
}

Config.MissionOptions = {
    boxesToPickUp = 1,                              -- Number of boxes to pick up
    truckModel = 'mule',                            -- Truck model to spawn
}

Config.DrugOptions = {
    {label='Weed', value='weed_brick'},
    {label='Cocaine', value='cokebaggy'},
    {label='Meth', value='meth'},
    {label='Oxy', value='oxy'},
}

-- Set the maximum amount of drug reward items to be given
Config.MaxDrugRewardAmount = 5

-- Add or remove mission rewards here. Ensure that the keys match the items in your inventory system.
Config.MissionRewards = {
    cash = 500,                                     -- ITEM  = REWARD AMOUNT
    water_bottle = 1,   
}
