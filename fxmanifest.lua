fx_version "cerulean"

description "Boilerplate for FiveM resources"
author "Lebubble Scripts"
version '1.0.0'

lua54 'yes'

game "gta5"

-- Use below if you want to use a NUI interface
--ui_page 'web/build/index.html'

shared_script  {
  'shared/config.lua',
  --'@ox_lib/init.lua'
}

-- Uncomment below if you will use oxmysql or ox-lib
--dependencies {
--  'ox_lib',
--  'oxmysql'
--}

client_script "client/**/*"

server_scripts {  
  -- Uncomment below if you will use oxmysql
  --'@oxmysql/lib/MySQL.lua',
  "server/**/*"
}

