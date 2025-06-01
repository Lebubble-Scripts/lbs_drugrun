-- Only edit this file is you know what you are doing!
if Config.Framework == 'qb' then
    print('^5[FRAMEWORK] Deteced QBCore Framework^7')
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "qbx" then 
    print("^1[FRAMEWORK] Detected QBX Framework^7")
    print("^1[FRAMEWORK] QBX IS NOT SUPPORTED YET^7")
elseif Config.Framework == 'esx' then
    print('^5[FRAMEWORK] Detected ESX Framework^7')
    print('^1[FRAMEWORK] ESX IS NOT SUPPORTED YET^7')
    --ESX = exports['es_extended']:getSharedObject()
else
    print('^1[FRAMEWORK] No supported framework detected. Please set Config.Framework to "qb".^7')
    print('^5[FRAMEWORK] Defaulting to QBCore Framework.^7')
    QBCore = exports['qb-core']:GetCoreObject()
end