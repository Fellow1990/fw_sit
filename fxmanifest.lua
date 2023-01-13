
fx_version 'adamant'

game 'gta5'

description 'ESX Sit & Fellow#3858 (ox conversion)'
lua54 'yes'
version '1.9.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'config.lua'
}

server_scripts {
	'server.lua'
}

client_scripts {
	'client.lua'
}

escrow_ignore {
	'config.lua'
}
