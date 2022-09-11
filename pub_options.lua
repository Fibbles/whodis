-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Misc settings

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_set_rank_filter(rank) -- pass nil to disable

	if rank then
		WHODIS_ADDON_DATA_CHAR.ALT_RANK = rank:lower()
		WHODIS_NS.msg_generic("Only showing guild notes for guild members with the rank '" .. rank .. "'.")
	else
		WHODIS_ADDON_DATA_CHAR.ALT_RANK = rank
		WHODIS_NS.msg_generic("Showing guild notes for all guild members regardless of rank.")
	end
end

WHODIS_NS.SLASH["rank-filter"] = {
func = whodis_set_rank_filter,
arg_str = "RankName",
help = [[Only show notes for guildies with this rank (off by default).
If your guild roster is well organised you may only want to display notes against players with rank 'alt' for example.
Leave RankName blank to disable this filter and show notes for all guildies.]]
}
WHODIS_NS.SLASH["rank"] = { deprecated = "rank-filter" }


local function whodis_note_filter(bool_str)

	if not bool_str then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.NOTE_FILTER = bool
	WHODIS_NS.msg_generic("Filtering of 'alt' and 'main' from the end of guild notes set to '" .. tostring(bool) .. "'.")
	WHODIS_NS.build_roster(true)
end

WHODIS_NS.SLASH["note-filter"] = {
func = whodis_note_filter,
arg_str = "True/False",
help = "If set to true, the addon will remove variations of 'alt' and 'main' from the end of guild notes."
}


local function whodis_colour_names(bool_str)

	if not bool_str then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.COLOUR_NAMES = bool
	WHODIS_NS.msg_generic("Name colouring set to '" .. tostring(bool) .. "'.")
	WHODIS_NS.build_roster(true)
end

WHODIS_NS.SLASH["colour_names"] = { 
func = whodis_colour_names,
arg_str = "True/False",
help = "When set to true, if the addon can recognise a note as a guild member's name it will colour the note based on their class."
}


local function whodis_colour_brackets(bool_str)

	if not bool_str then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.COLOUR_BRACKETS = bool
	WHODIS_NS.msg_generic("Bracket colouring set to '" .. tostring(bool) .. "'.")
end

WHODIS_NS.SLASH["colour_brackets"] = {
func = whodis_colour_brackets,
arg_str = "True/False",
help = [[If set to true, the addon will colour the brackets around the note grey.
If false, it will leave them the same colour as the channel's text.]]
}


local function whodis_hide_greeting(bool_str)

	if not bool_str then
		WHODIS_NS.warn_arguments_few()
		return
	end
	
	local bool = WHODIS_NS.str_to_bool(bool_str)

	WHODIS_ADDON_DATA.HIDE_GREETING = bool
	WHODIS_NS.msg_generic("Hide addon messages during load is now set to '" .. tostring(bool) .. "'.")
end

WHODIS_NS.SLASH["hide-greeting"] = {
func = whodis_hide_greeting,
arg_str = "True/False",
help = "If set to true, addon messages will not be displayed in the chat window during loading."
}