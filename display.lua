-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Helpers

local function whodis_rank_ok(rank)

	return (WHODIS_ADDON_DATA_CHAR.ALT_RANK == nil or 
		    rank == "n/a" or
		    WHODIS_ADDON_DATA_CHAR.ALT_RANK == rank:lower())
end

local function whodis_safe_get_roster_info(name)

	-- Blizzard is inconsistent about passing realm names as part of author names in chat filters
	-- Roster lookups need a realm name so this function works around that behaviour

	if WHODIS_NS.name_has_realm(name) then
		return WHODIS_ADDON_DATA_CHAR.ROSTER[name]
	else
		-- we have to assume the name is from our own realm
		return WHODIS_ADDON_DATA_CHAR.ROSTER[WHODIS_NS.format_name_full(name)]
	end	
end


-- Chat manipulation

local function whodis_chat_manip(self, event, msg, author, ...)

	local roster_info = whodis_safe_get_roster_info(author)
	
	if roster_info then
		local rank, _, note = unpack(roster_info)
			
		-- if we're checking for rank
		if whodis_rank_ok(rank) and note and note ~= '' then		
			local msg_mod = nil
			if WHODIS_ADDON_DATA.COLOUR_BRACKETS then
				msg_mod = "|cffd3d3d3(" .. note .. ")|r: " .. msg
			else
				msg_mod = "(" .. note .. "): " .. msg
			end
			return false, msg_mod, author, ...
		end
	end
	
	return false, msg, author, ...
end

local function whodis_login_manip(self, event, msg, ...)

	local link, data, name = strmatch(msg, "(|Hplayer:(.-)|h%[(.-)%]|h)")
	if link then
		
		local roster_info = whodis_safe_get_roster_info(name)
		
		if roster_info then
			local rank, _, note = unpack(roster_info)
				
			-- if we're checking for rank
			if whodis_rank_ok(rank) and note and note ~= '' then
			
				local search_name = "|h%[" .. name .. "%]|h"
			
				local format_note = nil
				if WHODIS_ADDON_DATA.COLOUR_BRACKETS then
					format_note = search_name .. " |cffd3d3d3%(" .. note .. "%)|r"
				else
					format_note = search_name .. " %(" .. note .. "%)"
				end
								
				local msg_mod = gsub(msg, search_name, format_note)
				
				return false, msg_mod, ...
			end
		end
	end
	
	return false, msg, ...
end

function WHODIS_NS.register_chat_filters()

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", whodis_chat_manip)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", whodis_chat_manip)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", whodis_login_manip)
end


-- Tooltip hook
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	
	-- the tooltip hook could in theory be called before the addon is fully initialised
	if WHODIS_NS.INITIALISED then
	
		local unit_name = self:GetUnit()
		
		if unit_name then
			
			local roster_info = whodis_safe_get_roster_info(unit_name)
		
			if roster_info then
				local rank, _, note = unpack(roster_info)
		
				if whodis_rank_ok(rank) and note and note ~= '' then
					local formatted_note = nil
					if WHODIS_ADDON_DATA.COLOUR_BRACKETS then
						formatted_note  = " |cffa9a9a9(" .. note .. ")|r"
					else
						formatted_note  = " (" .. note .. ")"
					end
					self:AppendText(formatted_note)
				end
			end
		end
	end
end)