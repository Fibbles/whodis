-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- GUI Addon Settings Page

-- setters just re-use slash commands since the functionality is already there
-- getters are required because any non table value stored directly will be a copy not a reference

local WHODIS_BOOL_OPTIONS = {
	
	["Note Filter"] = {
		command = WHODIS_NS.SLASH["note-filter"],
		getter = function() return WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER end
	},
		
	["Colour Names"] = {
		command = WHODIS_NS.SLASH["colour-names"],
		getter = function() return WHODIS_ADDON_DATA.SETTINGS.COLOUR_NAMES end
	},
		
	["Colour Brackets"] = {
		command = WHODIS_NS.SLASH["colour-brackets"],
		getter = function() return WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS end
	},
		
	["Hide Greeting"] = {
		command = WHODIS_NS.SLASH["hide-greeting"],
		getter = function() return WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING end
	},

	["Hide Player Note"] = {
		command = WHODIS_NS.SLASH["hide-player-note"],
		getter = function() return WHODIS_ADDON_DATA.SETTINGS.HIDE_PLAYER_NOTE end
	}
}

local WHODIS_TEXT_OPTIONS = {
	
	["Rank Whitelist"] = {
		command = WHODIS_NS.SLASH["rank-whitelist"],
		getter = function()

			local whitelist_string = ""
	
			if (WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST) then
				
				for key, _ in pairs(WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST) do
					whitelist_string = key .. ", " .. whitelist_string
				end
			end

			return whitelist_string
		end
	},

	["Custom Note Filter"] = {
		command = WHODIS_NS.SLASH["note-filter-custom"],
		getter = function() return WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER_CUSTOM end
	}
}


local function whodis_create_bool_options(parent_frame, anchor_frame, y_offset)
	
	local alt_offset = true
	local x_offset = 0
	local left_anchor = anchor_frame
	local anchor_point = "BOTTOMLEFT"
	
	for name, struct in pairs(WHODIS_BOOL_OPTIONS) do
	
		local cb = CreateFrame("CheckButton", nil, parent_frame, "ChatConfigCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", left_anchor, anchor_point, x_offset, y_offset)
		cb.Text:SetText(name)
		cb.tooltip = struct.command.help
		cb:SetChecked(struct.getter()) -- set the initial checked state

		cb:SetScript("OnClick", 
			function(self)
				-- all slash commands expect a string as an argument
				struct.command.func(tostring(not struct.getter()))
				self:SetChecked(struct.getter())
			end
		);
		
		-- ensure the state is still correct since the gui was last open
		-- state may have been altered by slash commands since
		cb:SetScript("OnShow", 
			function(self)
				self:SetChecked(struct.getter())
			end
		);
		
		if alt_offset then
			x_offset = 200
			y_offset = 0
			left_anchor = cb
			anchor_point = "TOPRIGHT"
		else
			x_offset = 0
			y_offset = 0
			anchor_point = "BOTTOMLEFT"
		end

		alt_offset = not alt_offset
	end
	
	return left_anchor
end


local function whodis_create_text_options(parent_frame, anchor_frame, y_offset)
	
	local left_anchor = anchor_frame
	local x_padding = 10

	for name, struct in pairs(WHODIS_TEXT_OPTIONS) do

		local label = parent_frame:CreateFontString(nil , "BORDER", "GameFontWhite")
		label:SetJustifyH("LEFT")
		label:SetPoint("TOPLEFT", left_anchor, "BOTTOMLEFT", 0, y_offset)
		label:SetText(name)

		local eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
		eb:SetSize(200, 22)
		eb:SetAutoFocus(false)
		eb:SetMultiLine(false)
		eb:SetPoint("LEFT", label, "RIGHT", math.max(0, 120 - label:GetWidth()) + x_padding, 0) -- tries to line up the editboxes vertically

		eb:SetScript("OnShow", function()
			eb:ClearFocus()
			eb:SetText(struct.getter() or "")
			eb:SetCursorPosition(0)
		end) -- each time the window is shown after initial set up

		-- needs to be manually called once for initial set up because it isn't called automatically when the settings window first opens
		eb:GetScript("OnShow")()

		eb:SetScript("OnEscapePressed", eb:GetScript("OnShow"))

		eb:SetScript("OnEnterPressed", function()
			eb:ClearFocus()
			struct.command.func(eb:GetText())
		end)

		local btn = CreateFrame("Button", nil, parent_frame, "UIPanelButtonTemplate")
		btn:SetPoint("LEFT", eb, "RIGHT", x_padding, 0)
		btn:SetText("Set")
		btn:SetWidth(80)
	
		btn:SetScript("OnClick", eb:GetScript("OnEnterPressed"))

		local info = parent_frame:CreateFontString(nil , "BORDER", "GameFontDisable")
		info:SetJustifyH("LEFT")
		info:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, y_offset)
		info:SetText(struct.command.help .. "\n ")

		left_anchor = info
	end

	return left_anchor
end


function WHODIS_NS.create_gui_settings_frame(parent_frame, x_offset, y_offset, y_section_padding)

	local gui_settings_frame = CreateFrame("Frame")
	gui_settings_frame.name = "Settings"
	gui_settings_frame.parent = parent_frame.name
		
	local title_header = WHODIS_NS.create_gui_title_header(gui_settings_frame, x_offset, y_section_padding)
	
	local general_opts_label = gui_settings_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	general_opts_label:SetJustifyH("LEFT")
	general_opts_label:SetPoint("TOPLEFT", title_header, "BOTTOMLEFT", 0, y_section_padding)
	general_opts_label:SetText("General Settings")

	local bool_opt_anchor = whodis_create_bool_options(gui_settings_frame, general_opts_label, y_offset)
	
	local advanced_opts_label = gui_settings_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	advanced_opts_label:SetJustifyH("LEFT")
	advanced_opts_label:SetPoint("TOPLEFT", bool_opt_anchor, "BOTTOMLEFT", 0, y_section_padding)
	advanced_opts_label:SetText("Advanced Settings")
	
	local text_opt_anchor = whodis_create_text_options(gui_settings_frame, advanced_opts_label, y_offset)
	
	return gui_settings_frame
end
