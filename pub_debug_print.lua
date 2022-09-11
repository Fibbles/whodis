-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Print functions for debug

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_print_roster()

	WHODIS_NS.msg_generic("Roster - Guild notes and custom notes")
	for name, roster_info in pairs(WHODIS_ADDON_DATA_CHAR.ROSTER) do
		local rank, class, note = unpack(roster_info)
		print("name: " .. name .. " || rank: " .. rank .. " || class: " .. class .. " || note: " .. note)
	end
end

WHODIS_NS.SLASH["print-roster"] = {
func = whodis_print_roster,
dev = true,
help = "Print a list of characters we will display a note for (guild roster + overrides)."
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
	
	local roster_info = WHODIS_ADDON_DATA_CHAR.ROSTER[full_name]
	
	if roster_info then
		local rank, class, note = unpack(roster_info)
		WHODIS_NS.msg_generic("name: " .. full_name .. " || rank: " .. rank .. " || class: " .. class .. " || note: " .. note)
	else
		WHODIS_NS.warn_generic("No player of that name saved in the roster.")
	end
end

WHODIS_NS.SLASH["print"] = {
func = whodis_print_player,
dev = true,
arg_str = "CharName",
help = "Print info about a specific character.\nCharacter name is not case sensitive unless the realm is also specified."
}


local function whodis_print_overrides()

	WHODIS_NS.msg_generic("Custom notes only")
	for name, note in pairs(WHODIS_ADDON_DATA.OVERRIDES) do
		print("name: " .. name .. " | note: " .. note)
	end
end

WHODIS_NS.SLASH["print-overrides"] = {
func = whodis_print_overrides,
dev = true,
help = "Print a list of characters with custom notes."
}


local function whodis_print_rank_filter()
	
	local rank = WHODIS_ADDON_DATA_CHAR.ALT_RANK
	
	if rank then
		WHODIS_NS.msg_generic("Only showing guild notes for guild members with the rank '" .. rank .. "'.")
	else
		WHODIS_NS.msg_generic("No rank filter set. Showing guild notes for all guild members regardless of rank.")
	end
end

WHODIS_NS.SLASH["print-rank-filter"] = {
func = whodis_print_rank_filter,
dev = true,
help = "Check what the current rank filter is set to."
}
WHODIS_NS.SLASH["print-rank"] = { deprecated = "print-rank-filter" }