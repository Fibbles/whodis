-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Roster and Overrides

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_set_override(name, note)

	if not name or name == "" then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	if not note then
		note = ""
	else
		-- colours codes must be stripped from the note as they will interfere with name lookups
		-- unlikely to be done via the command line but the GUI may accidentally pass back a previously coloured note
		note = WHODIS_NS.strip_colour_codes_from_str(note)
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

local function whodis_set_override_parser(arg_str)
	
	if not arg_str or arg_str == "" then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	name, note = WHODIS_NS.split_first_word_from_str(arg_str)
	
	whodis_set_override(name, note)
end

WHODIS_NS.SLASH["set"] = {
func = whodis_set_override_parser,
arg_str = "CharName Note",
help = [[Set a custom note.
If the character is a guildie this will override the default guild note.
Custom notes are visible to all characters on this account.
Character name is not case sensitive unless you specify a realm.]]
}


local function whodis_hide_note(name)
	whodis_set_override(name, nil)
end

WHODIS_NS.SLASH["hide"] = {
func = whodis_hide_note,
arg_str = "CharName",
help = [[Hide the character's note.
Useful if you want to prevent a default guild note from showing.
Character name is not case sensitive unless you specify a realm.]]
}


local function whodis_remove_override(name)

	if not name then
		WHODIS_NS.warn_arguments_few()
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

WHODIS_NS.SLASH["default"] = {
func = whodis_remove_override,
arg_str = "CharName",
help = [[Deletes any custom note.
For guild members this will cause the default guild note to show.
Character name is not case sensitive unless you specify a realm.]]
}
WHODIS_NS.SLASH["remove"] = { 
alias = "default"
}


local function whodis_reset()

	WHODIS_ADDON_DATA_CHAR.ROSTER = { }
	WHODIS_ADDON_DATA.OVERRIDES = { }
	WHODIS_NS.msg_generic("Roster and custom notes deleted. Use '/whodis populate' to refresh guild notes.")
end

WHODIS_NS.SLASH["delete-everything"] = {
func = whodis_reset,
help = [[Clear the cached guild and custom notes.
Be sure you want to call this because once your notes are gone, they can't be recovered.]]
}


local function whodis_populate()

	GuildRoster()
	WHODIS_NS.warn_generic("Forced an update of the guild roster. This is rate limited to once every 10 seconds by Blizzard so may not have been successful.")
	WHODIS_NS.build_roster()
end

WHODIS_NS.SLASH["populate"] = {
func = whodis_populate,
help = [[Update cached guild notes by forcing an update of the guild roster.
Useful if your guildmaster set some new guild notes after you logged in.]]
}