-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Roster and Overrides

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end


-- Swaps the wildcard for the target name (or nil if no target)
-- Returns the input if it is not the wildcard
local function whodis_swap_wildcard_for_target_name(str)

	if str == "*" then
		if UnitIsPlayer("target") then
			local name, realm = UnitFullName("target")

			if not realm then
				realm = WHODIS_NS.get_normalised_realm_name()
			end

			return name .. "-" .. realm
		else
			return nil
		end
	else
		return str
	end
end


local function whodis_default_or_remove(name)

	name = whodis_swap_wildcard_for_target_name(name)

	if not name then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local full_name = WHODIS_NS.fuzzy_lookup_full_name(name)
	
	local character_info = WHODIS_ADDON_DATA.CHARACTER_DB[full_name]

	if not character_info then
		WHODIS_NS.warn_generic("No note stored for character " .. full_name .. ".")
		return
	end

	if not character_info.guild_note then
		-- nothing to default to, just remove instead
		WHODIS_ADDON_DATA.CHARACTER_DB[full_name] = nil

		WHODIS_NS.msg_generic("Note removed for " .. full_name .. ".")
	else
		character_info.hidden = nil
		character_info.override_note = nil

		WHODIS_NS.msg_generic("Note reset to default for " .. full_name .. ".")
	end
	
	WHODIS_NS.build_roster(true)
end

WHODIS_NS.SLASH["default"] = {
func = whodis_default_or_remove,
arg_str = "CharName",
help = [[Deletes any custom note.
For guild members this will cause the default guild note to show.
Character name is not case sensitive unless you specify a realm.]]
}
WHODIS_NS.SLASH["remove"] = { 
alias = "default"
}


local function whodis_set_override(name, note)

	name = whodis_swap_wildcard_for_target_name(name)

	if not name or name == "" then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local full_name = WHODIS_NS.fuzzy_lookup_full_name(name)

	if note and note ~= "" then

		-- colours codes must be stripped from the note as they will interfere with name lookups
		-- unlikely to be done via the command line but the GUI may accidentally pass back a previously coloured note
		note = WHODIS_NS.strip_colour_codes_from_str(note)
	
		local character_info = WHODIS_ADDON_DATA.CHARACTER_DB[full_name] or {}
		
		character_info.override_note = note
		-- presumably if we're setting a custom note, it shouldn't stay hidden
		character_info.hidden = nil
		
		WHODIS_ADDON_DATA.CHARACTER_DB[full_name] = character_info

		WHODIS_NS.msg_generic("Custom note set for " .. full_name .. ".")

		WHODIS_NS.build_roster(true)
	else
		whodis_default_or_remove(full_name)
	end
end

local function whodis_set_override_parser(arg_str)
	
	if not arg_str or arg_str == "" then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local name, note = WHODIS_NS.split_first_word_from_str(arg_str)
	
	whodis_set_override(name, note)
end

WHODIS_NS.SLASH["set"] = {
func = whodis_set_override_parser,
arg_str = "CharName Note",
help = [[Set a custom note.
If the character is a guildie this will override the default guild note.
Custom notes are visible to all characters on this account.
Character name is not case sensitive unless you specify a realm.
The wildcard * can be used instead of a character name to set a note for your current target.]]
}


local function whodis_hide_note(name)

	name = whodis_swap_wildcard_for_target_name(name)

	if not name then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local full_name = WHODIS_NS.fuzzy_lookup_full_name(name)

	local character_info = WHODIS_ADDON_DATA.CHARACTER_DB[full_name]

	if not character_info then
		WHODIS_NS.warn_generic("No note stored for character " .. full_name .. ".")
		return
	end

	-- not a custom note
	if character_info.guild_note then
	
		character_info.hidden = true
		character_info.override_note = nil

		WHODIS_NS.msg_generic("Note hidden for " .. full_name .. ".")

		WHODIS_NS.build_roster(true)
	else
		-- don't bother hiding custom notes, just remove since they won't be automatically repopulated on login
		whodis_default_or_remove(full_name)
	end
end

WHODIS_NS.SLASH["hide"] = {
func = whodis_hide_note,
arg_str = "CharName",
help = [[Hide the character's note.
Useful if you want to prevent a default guild note from showing.
Character name is not case sensitive unless you specify a realm.]]
}


local function whodis_reset()

	WHODIS_ADDON_DATA.CHARACTER_DB = {}
	WHODIS_NS.FORMATTED_NOTE_DB = {}
	WHODIS_NS.msg_generic("Roster and custom notes deleted. Use '/whodis populate' to refresh guild notes.")
end

WHODIS_NS.SLASH["delete-everything"] = {
func = whodis_reset,
help = [[Clear the cached guild and custom notes.
Be sure you want to call this because once your notes are gone, they can't be recovered.]]
}


local function whodis_populate()

	WHODIS_NS.warn_generic("Forced an update of the guild roster. This is rate limited to once every 10 seconds by Blizzard so may not have been successful.")
	WHODIS_NS.build_roster()
end

WHODIS_NS.SLASH["populate"] = {
func = whodis_populate,
help = [[Update cached guild notes by forcing an update of the guild roster.
Useful if your guildmaster set some new guild notes after you logged in.]]
}