-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Parsing

WHODIS_NS.GUILD_ROSTER_LOADED = false

-- rebuilt each login based on the users formatting settings
WHODIS_NS.FORMATTED_NOTE_DB = {}

-- lookup table for converting charcter names to character-server names based on best guesses. rebuilt as above.
WHODIS_NS.FUZZY_CHARACTER_LOOKUP_DB = {}


local function whodis_nil_if_empty(note)
	
	local clean_note = WHODIS_NS.trim(note)

	if clean_note == "" then
		return nil
	else
		return clean_note
	end
end


local function whodis_poll_guild_roster(silent)
		
	-- ensure the local cache is populated, triggers a GUILD_ROSTER_UPDATE
	-- wont do anything if another addon called this in the last 10s
	-- this may be an issue on the addon's first run 
	C_GuildInfo.GuildRoster()

	local num_members = GetNumGuildMembers() or 0
	
	if num_members ~= 0 then 
		WHODIS_NS.GUILD_ROSTER_LOADED = true
	end
	
	for iii = 1, num_members do
		local name, rank, _, _, _, _, note, _, _, _, class = GetGuildRosterInfo(iii)

		-- weird bugfix
		-- all of these fields should contain something or be an empty string
		-- however if you log in and then zone into an instance quickly GetNumGuildMembers returns a number but GetGuildRosterInfo returns nil values
		if not name or not rank or not note or not class then
			WHODIS_NS.warn_generic("Failed to parse the guild roster. Client returned invalid data.")
			return
		end

		-- dont waste space storing blank notes
		local guild_note = whodis_nil_if_empty(note)
				
		-- keys are case sensitive
		-- names include server name "Player-Server"
		local character_info = WHODIS_ADDON_DATA.CHARACTER_DB[name]
		
		if character_info then	
			character_info.rank = rank:upper()
			character_info.class = class
			character_info.guild_note = guild_note
		else
			WHODIS_ADDON_DATA.CHARACTER_DB[name] = {rank = rank:upper(), class = class, guild_note = guild_note}
		end
	end
	
	if not silent then 
		WHODIS_NS.msg_generic("Parsed " .. num_members .. " members in the guild roster.")
	end
end


local function whodis_apply_note_filter(note)

	-- notes are already trimmed
	if note and note ~= "" then
		
		-- blank out any notes that are just variations of main or alt with punctuation either side
		note = gsub(note, "^[%p]*[mM][aA][iI][nN][%p]*$", "")
		note = gsub(note, "^[%p]*[aA][lL][tT][%p]*$", "")

		-- remove whitespace/punctuation followed by main or alt at the end
		note = gsub(note, "[%s%p]+[mM][aA][iI][nN]$", "")
		note = gsub(note, "[%s%p]+[aA][lL][tT]$", "")

		-- e.g. convert "Kallisto's alt" to "Kallisto"
		note = gsub(note, "'s$", "")

		-- remove main or alt followed by whitespace/punctuation at the beginning
		note = gsub(note, "^[mM][aA][iI][nN][%s%p]+", "")
		note = gsub(note, "^[aA][lL][tT][%s%p]+", "")
	end

	return note
end


local function whodis_apply_note_filter_custom(note)

	-- notes are already trimmed
	if note and note ~= "" then
		
		note = gsub(note, WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER_CUSTOM, "")
	end

	return note
end


local function whodis_colour_note_with_main_class(note, main_char)

	if not note or note == "" or not main_char or main_char == "" then
		return note
	end
	
	local character_info = WHODIS_ADDON_DATA.CHARACTER_DB[main_char]

	if character_info then
		local _, _, _, main_class_colour = GetClassColor(character_info.class)
		
		-- encapsulate the alt's note in the main's class colour code
		return "|c" .. main_class_colour .. note .. "|r"
	else
		return note
	end
end


local function whodis_is_char_filtered_by_rank_whitelist(char_info)

	-- if the whitelist is nil, rank filtering is disabled and all ranks are allowed
	if WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST == nil then
		return false
	end

	-- custom notes aren't affected by the whitelist and always show
	if char_info.override_note then
		return false
	end

	if char_info.rank and char_info.rank ~= "" then
		if WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST[char_info.rank] then
			return false
		end
	end

	return true
end

WHODIS_NS.is_char_filtered_by_rank_whitelist = whodis_is_char_filtered_by_rank_whitelist


local function whodis_is_filtered_as_player_char(name)

	if not WHODIS_ADDON_DATA.SETTINGS.HIDE_PLAYER_NOTE then
		return false
	else
		return (name == WHODIS_NS.CURRENT_PLAYER_CHARACTER)
	end
end


local function whodis_fuzzy_lookup_full_name(name)

	if not name or name == "" or WHODIS_NS.name_has_realm(name) then
		return name
	else
		local lookup_name = WHODIS_NS.FUZZY_CHARACTER_LOOKUP_DB[WHODIS_NS.format_name(name)]

		-- lookup may fail if the name is not in the fuzzy db. have to assume the character is on our current realm in that case
		return lookup_name or WHODIS_NS.format_name_current_realm(name)
	end
end

WHODIS_NS.fuzzy_lookup_full_name = whodis_fuzzy_lookup_full_name


local function whodis_generate_fuzzy_character_lookup()

	-- there will be collisions in this db with characters of the same name from different realms
	-- they shouldn't occur very often within the same guild though, so the benefits outweigh the downsides

	local player_realm = WHODIS_NS.get_normalised_realm_name()

	WHODIS_NS.FUZZY_CHARACTER_LOOKUP_DB = {}

	for name, character_info in pairs(WHODIS_ADDON_DATA.CHARACTER_DB) do

		local short_name, realm = strsplit("-", name)

		if short_name then
			if not WHODIS_NS.FUZZY_CHARACTER_LOOKUP_DB[short_name] or (realm == player_realm) then
				-- if there's already a character in the DB with the same name, only overwrite it if the current name is from the player's realm
				-- this will bias the fuzzy lookups to prefer characters on the player's own realm

				WHODIS_NS.FUZZY_CHARACTER_LOOKUP_DB[short_name] = name
			end
		end
	end
end


local function whodis_generate_formatted_notes()

	WHODIS_NS.FORMATTED_NOTE_DB = {}

	for name, character_info in pairs(WHODIS_ADDON_DATA.CHARACTER_DB) do
		
		local is_filtered = whodis_is_char_filtered_by_rank_whitelist(character_info) or whodis_is_filtered_as_player_char(name)

		if not character_info.hidden and not is_filtered then

			local working_note = character_info.override_note or character_info.guild_note

			-- dont apply note filters to custom notes
			-- presumably you want to see anything you put in a custom note
			if not character_info.override_note then

				if WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER then
					working_note = whodis_apply_note_filter(working_note)
				end

				if WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER_CUSTOM then
					working_note = whodis_apply_note_filter_custom(working_note)
				end
			end

			if WHODIS_ADDON_DATA.SETTINGS.COLOUR_NAMES then 
				local full_name = whodis_fuzzy_lookup_full_name(working_note)
				working_note = whodis_colour_note_with_main_class(working_note, full_name)
			end

			if working_note and working_note ~= "" then
				WHODIS_NS.FORMATTED_NOTE_DB[name] = working_note
			end
		end
	end
end


local function whodis_build_roster(silent)

	whodis_poll_guild_roster(silent)

	whodis_generate_fuzzy_character_lookup()

	whodis_generate_formatted_notes()
end

WHODIS_NS.build_roster = whodis_build_roster
