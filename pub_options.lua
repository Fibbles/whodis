-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Misc settings

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_generate_rank_whitelist(raw_whitelist_string)

	local raw_tbl = strsplittable(",", raw_whitelist_string)

	local rank_whitelist = {}

	-- removes any whitespace from the front or back of the rank, but leaves spaces between words intact allowing for multi-word ranks
	for key, value in pairs(raw_tbl) do
		-- setting the rank as the key lets us quickly check for it's existance with a hash lookup
		local clean_key = WHODIS_NS.trim(value:upper())

		if clean_key ~= "" then
			rank_whitelist[clean_key] = true
		end
	end

	-- if the whitelist doesn't have any entries, we want to return nil to disable whitelist filtering
	if next(rank_whitelist) == nil then
		rank_whitelist = nil
	end

	return rank_whitelist
end

local function whodis_set_rank_whitelist(rank_whitelist) -- pass nil to disable

	if rank_whitelist and rank_whitelist ~= "" then
		WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST = whodis_generate_rank_whitelist(rank_whitelist)
		WHODIS_NS.msg_generic("Only showing guild notes for guild members with one of the following ranks: '" .. rank_whitelist .. "'.")
	else
		WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST = nil
		WHODIS_NS.msg_generic("Showing guild notes for all guild members regardless of rank.")
	end

	WHODIS_NS.build_roster(true)
end

WHODIS_NS.SLASH["rank-whitelist"] = {
func = whodis_set_rank_whitelist,
arg_str = "RankName1, RankName2, ...",
help = [[Only show notes for guildies with a rank listed in the whitelist (off by default).
You may only want to display notes against players with rank 'alt' for example.
The whitelist is comma separated and not case sensitive.
Leave the whitelist blank to disable the feature and show notes for all guildies regardless of rank.]]
}
WHODIS_NS.SLASH["rank-filter"] = {
deprecated = true,
alias = "rank-whitelist"
}
WHODIS_NS.SLASH["rank"] = {
deprecated = true,
alias = "rank-whitelist"
}


local function bool_str_parser(bool_str)

	if not bool_str then
		WHODIS_NS.warn_arguments_few()
		return nil
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	if bool == nil then
		WHODIS_NS.warn_arguments_invalid()
	end

	return bool
end


local function whodis_note_filter(bool_str)

	local bool = bool_str_parser(bool_str)

	if bool ~= nil then
		WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER = bool
		WHODIS_NS.msg_generic("Filtering of 'alt' and 'main' from the beginning and end of guild notes set to '" .. tostring(bool) .. "'.")
		WHODIS_NS.build_roster(true)
	end
end

WHODIS_NS.SLASH["note-filter"] = {
func = whodis_note_filter,
arg_str = "True/False",
help = "If set to true, the addon will remove variations of 'alt' and 'main' from the beginning and end of guild notes."
}


local function whodis_note_filter_custom(pattern_str)

	if pattern_str and pattern_str ~= "" then
		WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER_CUSTOM = pattern_str
		WHODIS_NS.msg_generic("Guild notes are now being filtered with the custom pattern: " .. pattern_str)
	else
		WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER_CUSTOM = nil
		WHODIS_NS.msg_generic("Custom note filter disabled.")
	end

	WHODIS_NS.build_roster(true)
end

WHODIS_NS.SLASH["note-filter-custom"] = {
func = whodis_note_filter_custom,
arg_str = "Lua-Pattern",
help = [[Set a custom note filter. This is a feature intended only for advanced users.
The filter can be used in addition to or instead of the built-in note filter.
If the default filter is used, the custom filter will be run second.
Accepts Lua patterns. Set a blank/empty pattern to disable.
Details on Lua patterns can be found at: https://www.lua.org/manual/5.1/manual.html#5.4.1]]
}


local function whodis_colour_names(bool_str)

	local bool = bool_str_parser(bool_str)

	if bool ~= nil then
		WHODIS_ADDON_DATA.SETTINGS.COLOUR_NAMES = bool
		WHODIS_NS.msg_generic("Name colouring set to '" .. tostring(bool) .. "'.")
		WHODIS_NS.build_roster(true)
	end
end

WHODIS_NS.SLASH["colour-names"] = { 
func = whodis_colour_names,
arg_str = "True/False",
help = "When set to true, if the addon can recognise a note as a guild member's name it will colour the note based on their class."
}


local function whodis_colour_brackets(bool_str)

	local bool = bool_str_parser(bool_str)

	if bool ~= nil then
		WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS = bool
		WHODIS_NS.msg_generic("Bracket colouring set to '" .. tostring(bool) .. "'.")
	end
end

WHODIS_NS.SLASH["colour-brackets"] = {
func = whodis_colour_brackets,
arg_str = "True/False",
help = [[If set to true, the addon will colour the brackets around the note grey.
If false, it will leave them the same colour as the channel's text.]]
}


local function whodis_hide_greeting(bool_str)
	
	local bool = bool_str_parser(bool_str)

	if bool ~= nil then
		WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING = bool
		WHODIS_NS.msg_generic("Hide addon messages during load is now set to '" .. tostring(bool) .. "'.")
	end
end

WHODIS_NS.SLASH["hide-greeting"] = {
func = whodis_hide_greeting,
arg_str = "True/False",
help = "If set to true, addon messages will not be displayed in the chat window during loading."
}


local function whodis_hide_player_note(bool_str)

	local bool = bool_str_parser(bool_str)

	if bool ~= nil then
		WHODIS_ADDON_DATA.SETTINGS.HIDE_PLAYER_NOTE = bool
		WHODIS_NS.msg_generic("Automatic hiding of player character notes is now set to '" .. tostring(bool) .. "'.")
		WHODIS_NS.build_roster(true)
	end
end

WHODIS_NS.SLASH["hide-player-note"] = {
func = whodis_hide_player_note,
arg_str = "True/False",
help = "If set to true, the addon will automatically hide notes for the character you are currently playing."
}