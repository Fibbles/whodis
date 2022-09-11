-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Parsing

WHODIS_NS.GUILD_ROSTER_LOADED = false

local function whodis_poll_guild_roster(silent)
		
	local num_members = GetNumGuildMembers()
	
	-- only delete the cached roster if the guild roster is available
	-- this ensures that after the addon has been run once, we'll have something on the next
	-- session between the login and the guild roster becoming avilable
	if num_members ~= 0 then 
		WHODIS_ADDON_DATA_CHAR.ROSTER = { }
		WHODIS_NS.GUILD_ROSTER_LOADED = true
	end
	
	for iii = 1, num_members do
		local name, rank, _, _, class, _, note = GetGuildRosterInfo(iii)
				
		if WHODIS_ADDON_DATA.NOTE_FILTER then
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
		
		-- keys are case sensitive
		-- names include server name "Player-Server"
		WHODIS_ADDON_DATA_CHAR.ROSTER[name] = {rank, class, note}
	end
	
	if not silent then 
		WHODIS_NS.msg_generic("Parsed " .. num_members .. " members in the guild roster.")
	end
end

local function whodis_parse_overrides()

	-- replace default notes with overrides or create a new roster entry if they're not a guildie
	for name, note in pairs(WHODIS_ADDON_DATA.OVERRIDES) do
		local roster_info = WHODIS_ADDON_DATA_CHAR.ROSTER[name]
		if roster_info then
			-- overwriting rank ensures guildies with overrides still display if their rank is too low
			-- assumption is if you set a custom note, you didn't want to filter the rank filter to apply to them
			roster_info[1] = "n/a" 
			roster_info[3] = note
		else
			WHODIS_ADDON_DATA_CHAR.ROSTER[name] = {"n/a", "n/a", note}
		end
	end
end

local function whodis_colour_note_with_main_class(note)

	local main_name = WHODIS_NS.format_name_full(note)
	
	local main_roster_info = WHODIS_ADDON_DATA_CHAR.ROSTER[main_name]
	if main_roster_info then
		local _, main_class = unpack(main_roster_info)
		local _, _, _, main_class_colour = GetClassColor(main_class:upper())
		
		-- encapsulate the alt's note in the main's class colour code
		return "|c" .. main_class_colour .. note .. "|r"
	else
		return note
	end
end

local function whodis_colour_main_names()

	if WHODIS_ADDON_DATA.COLOUR_NAMES then 
		-- attempt to find the class of the guild member's main so we can colour the note
		for name, roster_info in pairs(WHODIS_ADDON_DATA_CHAR.ROSTER) do
			local _, class, note = unpack(roster_info)
		
			if class ~= "n/a" and note and note ~= '' then
				roster_info[3] = whodis_colour_note_with_main_class(note)
			end
		end
	end
end

local function whodis_build_roster(silent)

	whodis_poll_guild_roster(silent)
	whodis_parse_overrides()
	whodis_colour_main_names()
end

WHODIS_NS.build_roster = whodis_build_roster
