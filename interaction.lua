-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Print functions for debug

local function whodis_print_roster()

	WHODIS_NS.msg_generic("Roster - Guild notes and custom notes")
	for name, roster_info in pairs(WHODIS_ADDON_DATA_CHAR.ROSTER) do
		local rank, class, note = unpack(roster_info)
		print("name: " .. name .. " || rank: " .. rank .. " || class: " .. class .. " || note: " .. note)
	end
end

local function whodis_print_player(name)

	if not name then
		WHODIS_NS.warn_command()
		return
	end

	local full_name = name
	if not WHODIS_NS.name_has_realm(name) then
		full_name = WHODIS_NS.format_name_full(name)
	end
	
	local roster_info = WHODIS_ADDON_DATA_CHAR.ROSTER[full_name]
	
	if roster_info then
		local rank, class, note = unpack(roster_info)
		WHODIS_NS.msg_generic("name: " .. full_name .. " || rank: " .. rank .. " || class: " .. class .. " || note: " .. note)
	else
		WHODIS_NS.warn_generic("No player of that name saved in the roster.")
	end
end

local function whodis_print_overrides()

	WHODIS_NS.msg_generic("Custom notes only")
	for name, note in pairs(WHODIS_ADDON_DATA.OVERRIDES) do
		print("name: " .. name .. " | note: " .. note)
	end
end



-- Roster and Overrides

local function whodis_set_override(name, note)

	if not name then
		WHODIS_NS.warn_command()
		return
	end
	
	if not note then
		note = ""
	end
	
	local full_name = name
	if not WHODIS_NS.name_has_realm(name) then
		full_name = WHODIS_NS.format_name_full(name)
	end
	
	WHODIS_ADDON_DATA.OVERRIDES[full_name] = note
	
	if note == "" then
		WHODIS_NS.msg_generic("Note hidden for " .. full_name .. ".")
	else
		WHODIS_NS.msg_generic("Custom note set for " .. full_name .. ".")
	end
	
	WHODIS_NS.build_roster(true)
end

local function whodis_remove_override(name)

	if not name then
		WHODIS_NS.warn_command()
		return
	end
	
	local full_name = name
	if not WHODIS_NS.name_has_realm(name) then
		full_name = WHODIS_NS.format_name_full(name)
	end
	
	WHODIS_ADDON_DATA.OVERRIDES[full_name] = nil
	
	WHODIS_NS.msg_generic("Note reset to default for " .. full_name .. ".")
	WHODIS_NS.build_roster(true)
end

local function whodis_reset()

	WHODIS_ADDON_DATA_CHAR.ROSTER = { }
	WHODIS_ADDON_DATA.OVERRIDES = { }
	WHODIS_NS.msg_generic("Roster and custom notes deleted. Use '/whodis populate' to refresh guild notes.")
end

local function whodis_populate()

	GuildRoster()
	WHODIS_NS.warn_generic("Forced an update of the guild roster. This is rate limited to once every 10 seconds by Blizzard so may not have been successful.")
	WHODIS_NS.build_roster()
end



-- Misc settings

local function whodis_set_alt_rank(rank) -- pass nil to disable

	if rank then
		WHODIS_ADDON_DATA_CHAR.ALT_RANK = rank:lower()
		WHODIS_NS.msg_generic("Only showing guild notes for guild members with the rank '" .. rank .. "'.")
	else
		WHODIS_ADDON_DATA_CHAR.ALT_RANK = rank
		WHODIS_NS.msg_generic("Showing guild notes for all guild members regardless of rank.")
	end
end

local function whodis_print_alt_rank()
	
	local rank = WHODIS_ADDON_DATA_CHAR.ALT_RANK
	
	if rank then
		WHODIS_NS.msg_generic("Only showing guild notes for guild members with the rank '" .. rank .. "'.")
	else
		WHODIS_NS.msg_generic("No rank set. Showing guild notes for all guild members regardless of rank.")
	end
end

local function whodis_colour_names(bool_str)

	if not bool_str then
		WHODIS_NS.warn_command()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.COLOUR_NAMES = bool
	WHODIS_NS.msg_generic("Name colouring set to '" .. tostring(bool) .. "'.")
	WHODIS_NS.build_roster(true)
end

local function whodis_colour_brackets(bool_str)

	if not bool_str then
		WHODIS_NS.warn_command()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.COLOUR_BRACKETS = bool
	WHODIS_NS.msg_generic("Bracket colouring set to '" .. tostring(bool) .. "'.")
end

local function whodis_hide_greeting(bool_str)

	if not bool_str then
		WHODIS_NS.warn_command()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.HIDE_GREETING = bool
	WHODIS_NS.msg_generic("Hide addon messages during load is now set to '" .. tostring(bool) .. "'.")
end



-- Slash commands

SlashCmdList.WHODIS = function(arg_str)
	
	if not arg_str or arg_str == '' then
		return
	else
		-- Process arguments
		local args = {}
	
		for arg in arg_str:gmatch("%S+") do
			table.insert(args, arg)
		end
		
		local command = args[1]:lower()
		
		if command == "print" then -- print info about a specific player on the roster
			whodis_print_player(args[2]) 
		elseif command == "print-roster" then -- print the entire guild roster (filtered by rank) plus overrides
			whodis_print_roster() 
		elseif command == "export-roster" then -- export the guild roster as overrides. second argument is any string you want removed from the note before export
			WHODIS_NS.export_roster(args[2])
		elseif command == "delete-everything" then -- clear cached roster and all overrides
			whodis_reset()
		elseif command == "populate" then -- attempt to force a repoll of the guild roster
			whodis_populate()
		elseif command == "set" then -- set an override for the players's note, can be left blank, not restricted to guildies
			if args[4] then -- multiword notes
				local sub_str = args[1] .. " " .. args[2] .. " "
				whodis_set_override(args[2], gsub(arg_str, sub_str, ""))
			else
				whodis_set_override(args[2], args[3])
			end
		elseif command == "hide" then -- hides a player's note
				whodis_set_override(args[2], nil)
		elseif command == "remove" or command == "default" then -- remove an override of the member's note, display the default note if there is one
			whodis_remove_override(args[2])
		elseif command == "print-overrides" then -- print all overrides
			whodis_print_overrides()
		elseif command == "rank" or command == "rank-filter" then -- only show alt names for guildies with this rank (default is off)
			whodis_set_alt_rank(args[2]) -- pass nil to disable and show notes for all guildies
		elseif command == "print-rank" or command == "print-rank-filter" then -- check the current rank filter
			whodis_print_alt_rank()
		elseif command == "colour-names" then -- toggle name colouring
			whodis_colour_names(args[2]) -- true or false
		elseif command == "colour-brackets" then -- toggle bracket colouring
			whodis_colour_brackets(args[2]) -- true or false
		elseif command == "hide-greeting" then -- hide addon messages on load
			whodis_hide_greeting(args[2]) -- true or false
		elseif command == "help" then -- print the help message
			WHODIS_NS.msg_help()
		else
			WHODIS_NS.warn_command()
		end
	end
end
SLASH_WHODIS1 = "/whodis"