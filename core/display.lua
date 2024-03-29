-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Helpers

local function whodis_safe_get_formatted_note(name)

	-- Blizzard is inconsistent about passing realm names as part of author names in tooltips and chat filters
	-- If the character is on the same realm as the player, the realm name is omitted.
	-- Because we only ever need to add in the player's realm, we can avoid a more expensive fuzzy lookup
	-- Roster lookups need a realm name so this function works around that behaviour

	if WHODIS_NS.name_has_realm(name) then
		return WHODIS_NS.FORMATTED_NOTE_DB[name]
	else
		--WHODIS_NS.warn_generic(name .. "does not contain a realm.")
		return WHODIS_NS.FORMATTED_NOTE_DB[WHODIS_NS.format_name_current_realm(name)]
	end
end


-- Chat manipulation

local function whodis_chat_manip(self, event, msg, author, ...)

	local note = whodis_safe_get_formatted_note(author)
	
	if note and note ~= "" then		

		if WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS then
			note = "|cffd3d3d3(" .. note .. ")|r: "
		else
			note = "(" .. note .. "): "
		end

		msg = note .. msg
	end

	return false, msg, author, ...
end

local function whodis_achievement_manip(self, event, msg, author, ...)

	local note = whodis_safe_get_formatted_note(author)
	
	if note and note ~= "" then		
		
		local name_link, msg_body = WHODIS_NS.split_first_word_from_str(msg)

		if WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS then
			note = " |cffd3d3d3(" .. note .. ")|r "
		else
			note = " (" .. note .. ") "
		end

		msg = name_link .. note .. msg_body
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

	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", whodis_achievement_manip)
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", whodis_login_manip)
end


-- Tooltip hook
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	
	-- the tooltip hook could in theory be called before the addon is fully initialised
	if WHODIS_NS.INITIALISED then
			
		-- the tooltip's GetUnit method does return unit_name as the first value but it doesn't contain the realm name
		-- unit is mostly 'mouseover' for tooltips but might bear 'raidN' if hovering over raid frames etc
		local _, unit = self:GetUnit()

		if (not unit or not UnitExists(unit) or not UnitIsPlayer(unit)) then 
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