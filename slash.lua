-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Slash commands

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

SlashCmdList.WHODIS = function(raw_arg_str)

	-- raw_arg_str is everything that appears after /whodis
	
	if not raw_arg_str or raw_arg_str == '' then
		-- no command passed, open the gui instead
		WHODIS_NS.open_gui_frame()
		return
	end
	
	local command, arguments = WHODIS_NS.split_first_word_from_str(raw_arg_str)
	
	if arguments == "" then
		arguments = nil
	end
	
	local command_struct = WHODIS_NS.SLASH[command:lower()]
			
	if not command_struct then
		-- command doesn't exist
		WHODIS_NS.warn_command()
		return
	end
	
	if command_struct.deprecated then
		WHODIS_NS.warn_generic("This command is deprecated.")
	end
	
	if not command_struct.alias then
		-- arguments are passed as a single string which may be empty
		-- if the command requires multiple arguments it is expected to split the string itself
		command_struct.func(arguments)
	else
		WHODIS_NS.SLASH[command_struct.alias].func(arguments)
	end
end
SLASH_WHODIS1 = "/whodis"