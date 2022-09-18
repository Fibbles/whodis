-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- GUI Addon Settings Page

local function whodis_create_bool_options(parent_frame, anchor_frame, y_offset)

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


local function whodis_create_text_options(parent_frame, anchor_frame, y_offset)
	
	local x_padding = 20
	
	local label = parent_frame:CreateFontString(nil , "BORDER", "GameFontWhite")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	label:SetText("Rank Filter")
	
	local eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
	eb:SetSize(200, 22)
	eb:SetAutoFocus(false)
	eb:IsMultiLine(false)
	--eb:SetMaxLetters(30)
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

	return label
end


local function whodis_create_note_setter(parent_frame, anchor_frame, y_offset)
	
	local x_padding = 20
	
	local label = parent_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	label:SetText("Set Custom Note")
	
	local description = parent_frame:CreateFontString(nil , "BORDER", "GameFontWhite")
	description:SetJustifyH("LEFT")
	description:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, 0)
	description:SetText(WHODIS_NS.SLASH["set"].help)
	
	
	local name_eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
	name_eb:SetSize(200, 22)
	name_eb:SetAutoFocus(false)
	name_eb:IsMultiLine(false)
	--name_eb:SetMaxLetters(30)
	name_eb:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, 0)
	
	local note_eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
	note_eb:SetSize(200, 22)
	note_eb:SetAutoFocus(false)
	note_eb:IsMultiLine(false)
	--note_eb:SetMaxLetters(30)
	note_eb:SetPoint("LEFT", name_eb, "RIGHT", x_padding, 0)
	
		
	name_eb:SetScript("OnEscapePressed",
		function()
			name_eb:ClearFocus()
		end
	);

	name_eb:SetScript("OnTabPressed",
		function(self)
			name_eb:ClearFocus()
			note_eb:SetFocus()
		end
	);
	
	note_eb:SetScript("OnEscapePressed",
		function()
			note_eb:ClearFocus()
		end
	);
	
	
	local function note_setter()
		name_eb:ClearFocus()
		note_eb:ClearFocus()
		WHODIS_NS.SLASH["set"].func((name_eb:GetText() or "") .. " " .. (note_eb:GetText() or ""))
	end
	
	note_eb:SetScript("OnEnterPressed", note_setter)

		
	local btn = CreateFrame("Button", nil, parent_frame, "UIPanelButtonTemplate")
	btn:SetPoint("LEFT", note_eb, "RIGHT", x_padding, 0)
	btn:SetText("Set")
	btn:SetWidth(100)
	
	btn:SetScript("OnClick", note_setter)

	return name_eb
end


    local FramePool={};
     
    local function FramePool_Acquire()
        return table.remove(FramePool) or CreateFrame("Frame");--   Returns a frame if there is one in the pool or creates one if empty
    end
     
    local function FramePool_Release(frame)
        table.insert(frame);--  Stores frame in pool
    end
	

local function whodis_create_note_list(parent_frame, anchor_frame, y_offset)
	
	sf = CreateFrame("ScrollFrame", nil, parent_frame, "UIPanelScrollFrameTemplate")
	sf:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	sf:SetPoint("BOTTOMRIGHT", -45, 20)

	local eb = CreateFrame("EditBox", nil, sf)
	eb:SetMultiLine(true)
	eb:SetFontObject(ChatFontNormal)
	eb:SetWidth(600)
	eb:SetAutoFocus(false)
	eb:EnableMouse(false)
	eb:SetText("bleh")
	eb:SetCursorPosition(0)
		
	local function list_gen()
			
		local roster_list = ""
		
		for name, roster_info in pairs(WHODIS_ADDON_DATA_CHAR.ROSTER) do
			local rank, class, note = unpack(roster_info)
			roster_list = roster_list .. "Name: " .. name .. " || Custom: " .. tostring(rank == "n/a") .. " || Note: " .. note .. "\n"
		end
		
		eb:SetText(roster_list)
	end
	
	eb:SetScript("OnShow", list_gen) -- ensure the list is rebuilt after opening and closing the window
	
	sf:SetScrollChild(eb)

	return sf
end


-- Settings frame must created in a function as its children rely on data structures not present until after the addon initialises
function WHODIS_NS.create_settings_frame()

	local display_name = "Who Dis" -- ADDON_NAME is not formatted with spaces

	local settings_frame = CreateFrame("Frame")
	settings_frame.name = display_name
	
	local x_offset = 20
	local y_offset = -20
	local y_section_padding = -40
	
	local title_label = settings_frame:CreateFontString(nil , "BORDER", "GameFontNormalLarge")
	title_label:SetJustifyH("LEFT")
	title_label:SetPoint("TOPLEFT", settings_frame, "TOPLEFT", x_offset, y_offset)
	title_label:SetText(display_name)
	
	local account_opts_label = settings_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	account_opts_label:SetJustifyH("LEFT")
	account_opts_label:SetPoint("TOPLEFT", title_label, "TOPLEFT", 0, y_section_padding)
	account_opts_label:SetText("Per Account Settings")

	local bool_opt_anchor = whodis_create_bool_options(settings_frame, account_opts_label, y_offset)
	
	local char_opts_label = settings_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	char_opts_label:SetJustifyH("LEFT")
	char_opts_label:SetPoint("TOPLEFT", bool_opt_anchor, "TOPLEFT", 0, y_section_padding)
	char_opts_label:SetText("Per Character Settings")
	
	local text_opt_anchor = whodis_create_text_options(settings_frame, char_opts_label, y_offset)
	
	local note_setter_anchor = whodis_create_note_setter(settings_frame, text_opt_anchor, y_section_padding)
	
	local note_list_anchor = whodis_create_note_list(settings_frame, note_setter_anchor, y_section_padding)

	InterfaceOptions_AddCategory(settings_frame)
	
	WHODIS_NS.settings_frame = settings_frame
end

function WHODIS_NS.open_settings_frame()

	-- https://github.com/Stanzilla/WoWUIBugs/issues/89
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.settings_frame)
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.settings_frame) 
end

