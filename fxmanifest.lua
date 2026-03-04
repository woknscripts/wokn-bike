fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'wokn'
description 'wokn-bike'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
client_scripts {
    'client.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
dependencies {
    'ox_inventory',
    'ox_lib',
    'es_extended'
}
