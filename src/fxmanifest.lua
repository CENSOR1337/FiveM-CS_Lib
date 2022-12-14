-- [[ Informations ]]
fx_version "cerulean"
game "gta5"
lua54 "yes"

-- [[ Files ]]
files {
	"imports.lua",
	"imports/core/*.lua",
	"imports/core/classes/*.lua",
	"imports/**/client.lua",
	"imports/**/shared.lua"
}

-- [[ Resources ]]
shared_scripts {
	"imports.lua",
	"core/**/shared.lua",
}
server_scripts {
	"core/**/server.lua",
}
client_scripts {
	"core/**/client.lua",
}
