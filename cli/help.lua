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
		local example_str = "[ /whodis " .. command
		
		if command_struct.arg_str then
			example_str = example_str .. " " .. command_struct.arg_str
		end
		
		print(example_str .. " ]")
		
		if command_struct.deprecated then
			print("This command is deprecated.")
		end
		
		if command_struct.alias then
			print("This command is an alias. Please see the command [" .. command_struct.alias .. "] for details.")
			return
		end
		
		if command_struct.help then
			print(command_struct.help)
		end
	end
end

local function whodis_print_help(command, show_dev)

	if command then
		whodis_print_help_single(command)
	else
	
		if not show_dev then
			WHODIS_NS.msg_generic("Displaying help for all commands.")
		else
			WHODIS_NS.msg_generic("Displaying help for all debug commands.")
		end
		
		for key, val in pairs(WHODIS_NS.SLASH) do
			
			if (not val.dev and not show_dev) or (val.dev and show_dev) then
				print(" ")
				whodis_print_help_single(key)
			end
		end
	end
end

WHODIS_NS.SLASH["help"] = {
func = whodis_print_help,
arg_str = "Command",
help = [[Displays help for a specific command when 'command' is passed. Otherwise shows help for all commands.]]
}

local function whodis_print_help_dev(command)
	whodis_print_help(command, true)
end

WHODIS_NS.SLASH["help-debug"] = {
func = whodis_print_help_dev,
help = [[Shows help for less commonly used commands that are still useful for debugging.]]
}