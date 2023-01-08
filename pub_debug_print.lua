-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Print functions for debug

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_print_character_db()

	WHODIS_NS.msg_generic("Database of guild notes and custom notes")

	for name, char_info in pairs(WHODIS_ADDON_DATA.CHARACTER_DB) do
		local output_string = "name: " .. name

		for key, value in pairs(char_info) do
			output_string = output_string .. " || " .. key .. ": " .. value
		end

		print(output_string)
	end
end

WHODIS_NS.SLASH["print-character-db"] = {
func = whodis_print_character_db,
dev = true,
help = "Print a list of characters in the database (guild rosters + custom notes)."
}


local function whodis_print_player(name)

	if not name then
		WHODIS_NS.warn_arguments_few()
		return
	end

	local full_name = name
	if not WHODIS_NS.name_has_realm(name) then
		full_name = WHODIS_NS.format_name_full(name)
	end
	
	local char_info = WHODIS_ADDON_DATA.CHARACTER_DB[full_name]
	
	if char_info then
		local output_string = "name: " .. name

		for key, value in pairs(char_info) do
			output_string = output_string .. " || " .. key .. ": " .. value
		end

		WHODIS_NS.msg_generic(output_string)
	else
		WHODIS_NS.warn_generic("No player of that name saved in the database.")
	end
end

WHODIS_NS.SLASH["print"] = {
func = whodis_print_player,
dev = true,
arg_str = "CharName",
help = "Print info about a specific character.\nCharacter name is not case sensitive unless the realm is also specified."
}


local function whodis_print_formatted_notes()

	WHODIS_NS.msg_generic("Notes that have been formatted for display")
	for name, note in pairs(WHODIS_NS.FORMATTED_NOTE_DB) do
		print("name: " .. name .. " | note: " .. note)
	end
end

WHODIS_NS.SLASH["print-formatted-notes"] = {
func = whodis_print_formatted_notes,
dev = true,
help = "Print a list of notes that have been formatted for display based on user settings."
}


local function whodis_print_options()
	
	WHODIS_NS.msg_generic("Account wide options are currently set as:")
	
	for key, value in pairs(WHODIS_ADDON_DATA.SETTINGS) do
		if type(value) ~= "table" then
			print(key .. " : " .. tostring(value))
		end
	end
	
	WHODIS_NS.msg_generic("Per character options are currently set as:")
	
	for key, value in pairs(WHODIS_ADDON_DATA_CHAR.SETTINGS) do
		if type(value) ~= "table" then
			print(key .. " : " .. tostring(value))
		end
	end
end

WHODIS_NS.SLASH["print-options"] = {
func = whodis_print_options,
dev = true,
help = "Print a list of all addon options and their current values."
}
WHODIS_NS.SLASH["print-rank-filter"] = {
dev = true,
deprecated = true,
alias = "print-options"
}
WHODIS_NS.SLASH["print-rank"] = { 
dev = true,
deprecated = true,
alias = "print-options"
}