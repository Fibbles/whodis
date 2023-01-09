-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- GUI Addon Settings Page

local function whodis_create_bool_options(parent_frame, anchor_frame, y_offset)

	-- setters just re-use slash commands since the functionality is already there
	-- getters are required because any non table value stored directly will be a copy not a reference

	local options = {
	
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
		}
	}
	
	local alt_offset = true
	local x_offset = 0
	local left_anchor = anchor_frame
	local anchor_point = "BOTTOMLEFT"
	
	for name, struct in pairs(options) do
	
		local cb = CreateFrame("CheckButton", nil, parent_frame, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", left_anchor, anchor_point, x_offset, y_offset)
---@diagnostic disable-next-line: undefined-field
		cb.Text:SetText(name)
		cb.tooltipText = name
		cb.tooltipRequirement = struct.command.help		
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
	
	local x_padding = 10
	
	local label = parent_frame:CreateFontString(nil , "BORDER", "GameFontWhite")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	label:SetText("Rank Whitelist")
	
	local eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
	eb:SetSize(200, 22)
	eb:SetAutoFocus(false)
	eb:SetMultiLine(false)
	eb:SetPoint("LEFT", label, "RIGHT", x_padding, 0)
			
	local function rank_whitelist_getter()
		eb:ClearFocus()

		if (WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST) then
			local whitelist_string = ""

			for key, _ in pairs(WHODIS_ADDON_DATA.SETTINGS.RANK_WHITELIST) do
				whitelist_string = key .. ", " .. whitelist_string
			end

			eb:SetText(whitelist_string)
		else
			eb:SetText("")
		end

		eb:SetCursorPosition(0)
	end
	
	rank_whitelist_getter() -- initial set up
	eb:SetScript("OnShow", rank_whitelist_getter) -- each time the window is show after set up
	eb:SetScript("OnEscapePressed", rank_whitelist_getter)

	
	local function rank_whitelist_setter()
		eb:ClearFocus()
		WHODIS_NS.SLASH["rank-whitelist"].func(eb:GetText())
	end
	
	eb:SetScript("OnEnterPressed", rank_whitelist_setter)
		
	local btn = CreateFrame("Button", nil, parent_frame, "UIPanelButtonTemplate")
---@diagnostic disable-next-line: param-type-mismatch
	btn:SetPoint("LEFT", eb, "RIGHT", x_padding, 0)
	btn:SetText("Set")
	btn:SetWidth(80)
	
	-- dont use the default tooltipText field as it doesn't format correctly
	WHODIS_NS.tooltip_helper(btn, WHODIS_NS.SLASH["rank-whitelist"].help)
	
	btn:SetScript("OnClick", rank_whitelist_setter)

	return label
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
---@diagnostic disable-next-line: param-type-mismatch
	advanced_opts_label:SetPoint("TOPLEFT", bool_opt_anchor, "BOTTOMLEFT", 0, y_section_padding)
	advanced_opts_label:SetText("Advanced Settings")
	
	local text_opt_anchor = whodis_create_text_options(gui_settings_frame, advanced_opts_label, y_offset)
	
	InterfaceOptions_AddCategory(gui_settings_frame)
	
	return gui_settings_frame
end
