Config = {}


Config.Notify = 'qb'        -- 'ox', 'qb'
Config.Framework = 'qb'     -- 'qbx', 'qb',


if Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Set the cooldown time in seconds
-- 60 * 5 = 300 seconds = 5 minutes
-- 60 * 60 * 2 = 7200 seconds = 2 hours
Config.Cooldown = 10
