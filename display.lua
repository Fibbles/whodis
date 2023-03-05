-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Helpers

local function whodis_safe_get_formatted_note(name)

	-- Blizzard is inconsistent about passing realm names as part of author names in chat filters
	-- Roster lookups need a realm name so this function works around that behaviour

	return WHODIS_NS.FORMATTED_NOTE_DB[WHODIS_NS.fuzzy_lookup_full_name_unsafe(name)]
end


-- Chat manipulation

local function whodis_chat_manip(self, event, msg, author, ...)

	local note = whodis_safe_get_formatted_note(author)
	
	if note and note ~= "" then		
		local msg_mod = nil

		if WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS then
			msg_mod = "|cffd3d3d3(" .. note .. ")|r: " .. msg
		else
			msg_mod = "(" .. note .. "): " .. msg
		end

		return false, msg_mod, author, ...
	end

	return false, msg, author, ...
end

local function whodis_login_manip(self, event, msg, ...)

	local link, data, name = strmatch(msg, "(|Hplayer:(.-)|h%[(.-)%]|h)")

	if link then
		local note = whodis_safe_get_formatted_note(name)
		
		if note and note ~= "" then
			local search_name = "|h%[" .. name .. "%]|h"
		
			local bracket_note = nil

			if WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS then
				bracket_note = search_name .. " |cffd3d3d3%(" .. note .. "%)|r"
			else
				bracket_note = search_name .. " %(" .. note .. "%)"
			end
							
			local msg_mod = gsub(msg, search_name, bracket_note)
			
			return false, msg_mod, ...
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
			
		-- the tooltip's GetUnit method does return unit_name as the first value but it doesn't contain the realm name
		-- unit is mostly 'mouseover' for tooltips but might bear 'raidN' if hovering over raid frames etc
		local _, unit = self:GetUnit()

		if (not unit or not UnitExists(unit)) then 
			return
		end
		
		local unit_name, unit_realm = UnitName(unit)
		
		if unit_realm and unit_realm ~= "" then
			unit_name = unit_name .. "-" .. unit_realm
		end
		
		if unit_name then
			local note = whodis_safe_get_formatted_note(unit_name)
				
			if note and note ~= "" then
				local bracket_note = nil

				if WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS then
					bracket_note  = " |cffa9a9a9(" .. note .. ")|r"
				else
					bracket_note  = " (" .. note .. ")"
				end

				self:AppendText(bracket_note)
			end
		end
	end
end)