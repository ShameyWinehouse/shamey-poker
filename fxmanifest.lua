fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_scripts {
	"client/*.lua",
}

server_scripts {
	"server/*.lua",
	"@oxmysql/lib/MySQL.lua",
}

shared_scripts {
	"config.lua",
	"shared/*.lua",
	"shared/**/*.lua",
}

files {
	"ui/dist/*",
	"ui/dist/**/*",
	"ui/dist/img/card/*",
  }
ui_page "ui/dist/index.html"


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'