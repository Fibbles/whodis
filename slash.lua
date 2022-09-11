-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Slash commands

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

SlashCmdList.WHODIS = function(raw_arg_str)

	-- raw_arg_str is everything that appears after /whodis
	
	if not raw_arg_str or raw_arg_str == '' then
		-- no command passed
		WHODIS_NS.warn_command()
		return
	end
	
	-- the raw_arg_str split into individual words
	local word_array = {}

	-- number of words after /whodis
	-- must be at least 1 as the first word is the command
	local word_count = 0
	
	for word in raw_arg_str:gmatch("%S+") do
		table.insert(word_array, word)
		
		word_count = word_count + 1
		if word_count == 2 then
			break
		end
	end
	
	local command_struct = WHODIS_NS.SLASH[word_array[1]:lower()]
			
	if not command_struct then
		-- command doesn't exist
		WHODIS_NS.warn_command()
	else
		if not command_struct.deprecated then
			-- ignore the first word which is the command
			-- all slash commands must accept variable args, even if the do nothing with them
			command_struct.func(unpack(word_array, 2))
		else
			command_struct_redir = WHODIS_NS.SLASH[command_struct.deprecated]
			
			WHODIS_NS.warn_generic("This command is deprecated. Please use the command [" .. command_struct.deprecated .. "] instead.")
			
			command_struct_redir.func(unpack(word_array, 2))
		end
	end
end
SLASH_WHODIS1 = "/whodis"