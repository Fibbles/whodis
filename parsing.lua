-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Parsing

WHODIS_NS.GUILD_ROSTER_LOADED = false

-- rebuilt each login based on the users formatting settings
WHODIS_NS.FORMATTED_NOTE_DB = {}


local function whodis_poll_guild_roster(silent)
		
	-- ensure the local cache is populated, triggers a GUILD_ROSTER_UPDATE
	-- wont do anything if another addon called this in the last 10s
	-- this may be an issue on the addon's first run 
	C_GuildInfo.GuildRoster()

	local num_members = GetNumGuildMembers()
	
	if num_members ~= 0 then 
		WHODIS_NS.GUILD_ROSTER_LOADED = true
	end
	
	for iii = 1, num_members do
		local name, rank, _, _, _, _, note, _, _, _, class = GetGuildRosterInfo(iii)

		-- dont waste space storing blank notes
		local guild_note = nil
		if note ~= "" then
			guild_note = note
		end
				
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

	if note and note ~= "" then
		-- e.g. convert "Kallisto's alt" to "Kallisto"
		note = gsub(note, "'s ALT$", "")
		note = gsub(note, "'s Alt$", "")
		note = gsub(note, "'s alt$", "")
		note = gsub(note, " ALT$", "")
		note = gsub(note, " Alt$", "")
		note = gsub(note, " alt$", "")
		
		note = gsub(note, "'s MAIN$", "")
		note = gsub(note, "'s Main$", "")
		note = gsub(note, "'s main$", "")
		note = gsub(note, " MAIN$", "")
		note = gsub(note, " Main$", "")
		note = gsub(note, " main$", "")
	end

	return note
end

local function whodis_colour_note_with_main_class(note)

	local main_name = WHODIS_NS.format_name_full(note)
	
	local character_info = WHODIS_ADDON_DATA.CHARACTER_DB[main_name]
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

local function whodis_generate_formatted_notes()

	WHODIS_NS.FORMATTED_NOTE_DB = {}

	for name, character_info in pairs(WHODIS_ADDON_DATA.CHARACTER_DB) do
		
		local is_filtered = whodis_is_char_filtered_by_rank_whitelist(character_info)

		if not character_info.hidden and not is_filtered then

			local working_note = character_info.override_note or character_info.guild_note

			if working_note then
				if WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER then
					working_note = whodis_apply_note_filter(working_note)
				end

				if WHODIS_ADDON_DATA.SETTINGS.COLOUR_NAMES then 
						working_note = whodis_colour_note_with_main_class(working_note)
				end

				WHODIS_NS.FORMATTED_NOTE_DB[name] = working_note
			end
		end
	end
end

local function whodis_build_roster(silent)

	whodis_poll_guild_roster(silent)
	whodis_generate_formatted_notes()
end

WHODIS_NS.build_roster = whodis_build_roster
