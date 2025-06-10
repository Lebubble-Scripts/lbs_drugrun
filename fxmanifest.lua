fx_version 'cerulean'
lua54 'yes'
game 'gta5'

server_scripts {
    'server/orm.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/server.lua',
    'server/callbacks.lua',

}

client_scripts {
    'client/functions.lua',
    'client/variables.lua',
    'client/client.lua',
    'client/drugrun.lua',
}

shared_script {
    'shared/functions.lua',
    'shared/config.lua',
    'shared/bridge.lua',
    '@ox_lib/init.lua',
}

dependencies {
    'ox_lib',
    'oxmysql'
}
