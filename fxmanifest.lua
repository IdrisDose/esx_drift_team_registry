fx_version 'bodacious'

game 'gta5'

description 'ESX Drift Teams'

version '0.1.0'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
	'html/style.css'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua'
}

dependencies {
	'es_extended'
}