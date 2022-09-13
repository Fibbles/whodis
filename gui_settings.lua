-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- GUI Addon Settings Page

local function create_bool_options(parent_frame, anchor_frame, y_offset)

	-- setters just re-use slash commands since the functionality is already there
	-- getters are required because any non table value stored directly will be a copy not a reference

	local options = {
	
		["Note Filter"] = {
			command = WHODIS_NS.SLASH["note-filter"],
			getter = function() return WHODIS_ADDON_DATA.NOTE_FILTER end
		},
			
		["Colour Names"] = {
			command = WHODIS_NS.SLASH["colour-names"],
			getter = function() return WHODIS_ADDON_DATA.COLOUR_NAMES end
		},
			
		["Colour Brackets"] = {
			command = WHODIS_NS.SLASH["colour-brackets"],
			getter = function() return WHODIS_ADDON_DATA.COLOUR_BRACKETS end
		},
			
		["Hide Greeting"] = {
			command = WHODIS_NS.SLASH["hide-greeting"],
			getter = function() return WHODIS_ADDON_DATA.HIDE_GREETING end
		}
	}
	
	for name, struct in pairs(options) do
	
		local cb = CreateFrame("CheckButton", nil, parent_frame, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
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
		
		y_offset = 0
		anchor_frame = cb
	end
	
	return anchor_frame
end

local function create_text_options(parent_frame, anchor_frame, y_offset)
	
	local x_padding = 20
	
	local label = parent_frame:CreateFontString(nil , "BORDER", "GameFontWhite")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	label:SetText("Rank Filter")
	
	local eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
    eb:SetSize(200,22)
    eb:SetAutoFocus(false)
	eb:IsMultiLine(false)
    eb:SetMaxLetters(30)
    eb:SetPoint("LEFT", label, "RIGHT", x_padding, 0)
			
	local function rank_filter_getter()
		eb:ClearFocus()
		eb:SetText(WHODIS_ADDON_DATA_CHAR.ALT_RANK or "")
		eb:SetCursorPosition(0)
	end
	
	rank_filter_getter() -- initial set up
	eb:SetScript("OnShow", rank_filter_getter) -- each time the window is show after set up
	eb:SetScript("OnEscapePressed", rank_filter_getter)

	
	local function rank_filter_setter()
		eb:ClearFocus()
		WHODIS_NS.SLASH["rank-filter"].func(eb:GetText())
	end
	
    eb:SetScript("OnEnterPressed", rank_filter_setter)
		
	local btn = CreateFrame("Button", nil, parent_frame, "UIPanelButtonTemplate")
	btn:SetPoint("LEFT", eb, "RIGHT", x_padding, 0)
	btn:SetText("Okay")
	btn:SetWidth(100)
	
	btn:SetScript("OnClick", rank_filter_setter)

	return eb
end

-- Settings frame must created in a function as its children rely on data structures not present until after the addon initialises
function WHODIS_NS.create_settings_frame()

	local settings_frame = CreateFrame("Frame")
	settings_frame.name = ADDON_NAME
	
	local x_offset = 20
	local y_offset = -20
	local y_section_padding = -40
	
	local title_label = settings_frame:CreateFontString(nil , "BORDER", "GameFontNormalLarge")
	title_label:SetJustifyH("LEFT")
	title_label:SetPoint("TOPLEFT", settings_frame, "TOPLEFT", x_offset, y_offset)
	title_label:SetText(ADDON_NAME)
	
	local account_opts_label = settings_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	account_opts_label:SetJustifyH("LEFT")
	account_opts_label:SetPoint("TOPLEFT", title_label, "TOPLEFT", 0, y_section_padding)
	account_opts_label:SetText("Per account settings:")

	last_bool_opt = create_bool_options(settings_frame, account_opts_label, y_offset)
	
	local char_opts_label = settings_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	char_opts_label:SetJustifyH("LEFT")
	char_opts_label:SetPoint("TOPLEFT", last_bool_opt, "TOPLEFT", 0, y_section_padding)
	char_opts_label:SetText("Per character settings:")
	
	last_text_opt = create_text_options(settings_frame, char_opts_label, y_offset)

	InterfaceOptions_AddCategory(settings_frame)
	
	WHODIS_NS.settings_frame = settings_frame
end

function WHODIS_NS.open_settings_frame()

	-- https://github.com/Stanzilla/WoWUIBugs/issues/89
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.settings_frame)
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.settings_frame) 
end

