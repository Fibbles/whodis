-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...

-- Messages and Warnings

local WHODIS_CHAT_PREFIX = "|cFFFFD700Who Dis:|r "

local function whodis_warn_generic(text)
	print(WHODIS_CHAT_PREFIX .. "|cFFFF0000" .. text .. "|r")
end

local function whodis_msg_generic(text)
	print(WHODIS_CHAT_PREFIX .. "|cFFFFFFFF" .. text .. "|r")
end

WHODIS_NS.warn_generic = whodis_warn_generic
WHODIS_NS.msg_generic = whodis_msg_generic



function WHODIS_NS.warn_command()
	whodis_warn_generic("Please pass a valid command. Try [ /whodis help ] or see the readme for details.")
end

function WHODIS_NS.warn_arguments_few()
	whodis_warn_generic("Too few arguments for this command. Try [ /whodis help ] or see the readme for details.")
end

function WHODIS_NS.warn_arguments_many()
	whodis_warn_generic("Too many arguments for this command. Try [ /whodis help ] or see the readme for details.")
end

function WHODIS_NS.warn_arguments_invalid()
	whodis_warn_generic("Invalid arguments for this command. Try [ /whodis help ] or see the readme for details.")
end



function WHODIS_NS.msg_init()

	if WHODIS_NS.INITIALISED then

		if not WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING then

			whodis_msg_generic("v" .. WHODIS_NS.VERSION.CURRENT .. " loaded.")
		end
	else
		whodis_warn_generic("Failed to initialise.")
	end
end
