Config = {}


Config.Notify = 'qb'        -- 'ox', 'qb'
Config.Framework = 'qb'     -- 'qbx', 'qb',


-- Do not change this unless you know what you are doing
if Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'qbx' then
    qbx = exports.qbx_core
end