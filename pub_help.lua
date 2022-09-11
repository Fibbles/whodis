-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Text based help system

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_print_help_single(command)
	
	local command_struct = WHODIS_NS.SLASH[command:lower()]
			
	if not command_struct then
		-- command doesn't exist
		WHODIS_NS.warn_command()
	else		
		if command_struct.deprecated then
			print("This command is deprecated. Please use the command [" .. command_struct.deprecated .. "] instead.")
			return
		end
		
		if command_struct.arg_str then
			print("Arguments: " .. command_struct.arg_str)
		end
		
		if command_struct.help then
			print(command_struct.help)
		end
	end
end

local function whodis_print_help(command, show_dev)

	if command then
		WHODIS_NS.msg_generic("Displaying help for the command [" .. command .. "] if it exists.")
		whodis_print_help_single(command)
	else
		WHODIS_NS.msg_generic("Displaying help for all commands.")
		
		for key, val in pairs(WHODIS_NS.SLASH) do
		
			if not val.dev or (val.dev and show_dev) then
				print(" ")
				print("Command: " .. key)
				whodis_print_help_single(key)
			end
		end
	end
end

WHODIS_NS.SLASH["help"] = {
func = whodis_print_help,
arg_str = "Command",
help = [[Type '/whodis help' for a full list of commands.
Type '/whodis help command' to view help only for that command.]]
}

local function whodis_print_help_dev(command)
	whodis_print_help(command, true)
end

WHODIS_NS.SLASH["help-debug"] = {
func = whodis_print_help_dev,
help = [[Shows less commonly used commands that are still useful for debugging.
Type '/whodis help-debug' for a full list of debug commands.
Type '/whodis help command' to view help only for that command.]]
}