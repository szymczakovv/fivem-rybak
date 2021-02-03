  --[ esx_rybak - powered by: https://szymczakovv.pl ]--
-- Nazwa: esx_rybak
-- Autor: szymczakovv#1937
-- Data: 03/02/2021
-- Wersja: 1.0
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
  'config.lua',
  'client/main.lua'
}

server_scripts {
  'config.lua',
  '@mysql-async/lib/MySQL.lua',
  'server/main.lua'
}









