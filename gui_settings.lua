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
	
	local alt_offset = true
	local x_offset = 0
	local left_anchor = anchor_frame
	local anchor_point = "BOTTOMLEFT"
	
	for name, struct in pairs(options) do
	
		local cb = CreateFrame("CheckButton", nil, parent_frame, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", left_anchor, anchor_point, x_offset, y_offset)
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
	btn:SetText("Set")
	btn:SetWidth(80)
	
	btn:SetScript("OnClick", rank_filter_setter)

	return label
end


local function whodis_create_note_setter(parent_frame, anchor_frame, y_offset)
	
	local x_padding = 10
		
	local name_eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
	name_eb:SetSize(210, 22)
	name_eb:SetAutoFocus(false)
	name_eb:IsMultiLine(false)
	--name_eb:SetMaxLetters(30)
	name_eb:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, 0)
	
	local note_eb = CreateFrame("EditBox", nil, parent_frame, "InputBoxTemplate")
	note_eb:SetSize(210, 22)
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
	btn:SetWidth(40)
	
	btn:SetScript("OnClick", note_setter)

	return name_eb
end


local function whodis_create_note_row(parent_frame, anchor_frame, y_offset)
	
	local x_padding = 10
	local row_width = parent_frame:GetWidth()
	local row_height = 30
	
	local row_frame = CreateFrame("Frame", nil, parent_frame)
	row_frame:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	row_frame:SetSize(row_width, row_height)
	
	
	row_frame.name_label = row_frame:CreateFontString(nil , "BORDER", "GameFontWhite")
	row_frame.name_label:SetJustifyH("LEFT")
	row_frame.name_label:SetPoint("LEFT", row_frame, "LEFT", 0, 0)
	row_frame.name_label:SetText("AlanSmithee-ALongServerName-SomeExtraText")
	row_frame.name_label:SetWidth(210)
	row_frame.name_label:SetWordWrap(false)
	
	
	row_frame.note_eb = CreateFrame("EditBox", nil, row_frame, "InputBoxTemplate")
	row_frame.note_eb:SetSize(210, 22)
	row_frame.note_eb:SetAutoFocus(false)
	row_frame.note_eb:IsMultiLine(false)
	--note_eb:SetMaxLetters(30)
	row_frame.note_eb:SetPoint("LEFT", row_frame.name_label, "RIGHT", x_padding, 0)
	row_frame.note_eb:SetText("Some Note")
	row_frame.note_eb:SetCursorPosition(0)
	
	local function cancel_edit(self)
		self:ClearFocus()
	end
		
	row_frame.note_eb:SetScript("OnEscapePressed", cancel_edit)
	
	
	local function note_setter(self)
		self:ClearFocus()
		local name = self:GetParent().name_label:GetText()
		local note = self:GetParent().note_eb:GetText()
		WHODIS_NS.SLASH["set"].func((name or "") .. " " .. (note or ""))
	end
	
	row_frame.note_eb:SetScript("OnEnterPressed", note_setter)

		
	row_frame.set_button = CreateFrame("Button", nil, row_frame, "UIPanelButtonTemplate")
	row_frame.set_button:SetPoint("LEFT", row_frame.note_eb, "RIGHT", x_padding, 0)
	row_frame.set_button:SetText("Set")
	row_frame.set_button:SetWidth(40)
	row_frame.set_button:SetScript("OnClick", note_setter)
	
	row_frame.default_button = CreateFrame("Button", nil, row_frame, "UIPanelButtonTemplate")
	row_frame.default_button:SetPoint("LEFT", row_frame.set_button, "RIGHT", 0, 0)
	row_frame.default_button:SetText("Default")
	row_frame.default_button:SetWidth(60)
	--row_frame.default_button:SetScript("OnClick", note_setter)

	row_frame.hide_button = CreateFrame("Button", nil, row_frame, "UIPanelButtonTemplate")
	row_frame.hide_button:SetPoint("LEFT", row_frame.default_button, "RIGHT", 0, 0)
	row_frame.hide_button:SetText("Hide")
	row_frame.hide_button:SetWidth(40)

	return row_frame
end

local function whodis_create_note_grid(parent_frame, anchor_frame, y_offset)

	local x_padding = 10
	local grid_width = 600
	local grid_height = 200
	local num_rows = 10
	
	local grid_frame = CreateFrame("Frame", nil, parent_frame)
	grid_frame:SetPoint("TOPLEFT", anchor_frame, "BOTTOMLEFT", 0, y_offset)
	grid_frame:SetSize(grid_width, grid_height)
	
	grid_frame.name_column_label = grid_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	grid_frame.name_column_label:SetJustifyH("LEFT")
	grid_frame.name_column_label:SetPoint("TOPLEFT", grid_frame, "TOPLEFT", 0, 0)
	grid_frame.name_column_label:SetText("Character Name")
	grid_frame.name_column_label:SetWidth(210)
	--row_frame.name_label:SetWordWrap(false)
	
	grid_frame.note_column_label = grid_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	grid_frame.note_column_label:SetJustifyH("LEFT")
	grid_frame.note_column_label:SetPoint("LEFT", grid_frame.name_column_label, "RIGHT", x_padding, 0)
	grid_frame.note_column_label:SetText("Note")
	grid_frame.note_column_label:SetWidth(210)
	
	grid_frame.note_setter = whodis_create_note_setter(grid_frame, grid_frame.name_column_label, y_section_padding)
	
	grid_frame.rows = {}
	
	local last_anchor = grid_frame.note_setter
	
	for iii = 1, num_rows do
		local current_row = whodis_create_note_row(grid_frame, last_anchor, 0)
		last_anchor = current_row
		table.insert(grid_frame.rows, current_row)
	end


	grid_frame.prev_button = CreateFrame("Button", nil, grid_frame, "UIPanelButtonTemplate")
	grid_frame.prev_button:SetPoint("TOPLEFT", last_anchor, "BOTTOMLEFT", 0, 0)
	grid_frame.prev_button:SetText("Previous")
	grid_frame.prev_button:SetWidth(80)
	
	local function prev_page(self)
		WHODIS_NS.update_settings_note_grid(self:GetParent().current_page - 1, 10)
	end
	grid_frame.prev_button:SetScript("OnClick", prev_page)
	
	grid_frame.page_num_label = grid_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	grid_frame.page_num_label:SetJustifyH("CENTER")
	grid_frame.page_num_label:SetPoint("LEFT", grid_frame.prev_button, "RIGHT", x_padding, 0)
	grid_frame.page_num_label:SetText("Page Num")
	grid_frame.page_num_label:SetWidth(80)

	grid_frame.next_button = CreateFrame("Button", nil, grid_frame, "UIPanelButtonTemplate")
	grid_frame.next_button:SetPoint("LEFT", grid_frame.page_num_label, "RIGHT", x_padding, 0)
	grid_frame.next_button:SetText("Next")
	grid_frame.next_button:SetWidth(80)
	
	local function next_page(self)
		WHODIS_NS.update_settings_note_grid(self:GetParent().current_page + 1, 10)
	end
	grid_frame.next_button:SetScript("OnClick", next_page)


	return grid_frame
end

function WHODIS_NS.update_settings_note_grid(page_num, page_size)
	
	-- sort the roster alpabetically
	
	local names = {}
	for char_name, _ in pairs(WHODIS_ADDON_DATA_CHAR.ROSTER) do
		table.insert(names, char_name)
	end
	table.sort(names)
	
	local num_names = table.getn(names)
	WHODIS_NS.settings_frame.note_grid.num_names = num_names
	
	local num_pages = math.ceil(num_names / page_size)
	WHODIS_NS.settings_frame.note_grid.num_pages = num_pages
	
	page_num = math.max(1, math.min(page_num, num_pages))
	WHODIS_NS.settings_frame.note_grid.current_page = page_num
	
	-- modulo with 1 based inclusive indexing really sucks
	local begin_index = math.min(((page_num - 1) * page_size) + 1, num_names)
	local end_index = math.min(((page_num - 1) * page_size) + page_size, num_names)
	
	for iii = begin_index, begin_index + page_size - 1 do
		
		local row_num = ((iii - 1) % page_size) + 1
		
		local row = WHODIS_NS.settings_frame.note_grid.rows[row_num]
			
		if iii <= end_index then
			
			row:Show()
			
			row.name_label:SetText(names[iii])
			
			local rank, _, note = unpack(WHODIS_ADDON_DATA_CHAR.ROSTER[names[iii]])
			
			row.note_eb:SetText(note)
			row.note_eb:SetCursorPosition(0)
			
			-- custom notes always have rank of "n/a"
			if rank ~= "n/a" then
				row.default_button:Disable() -- no custom note, it's already on the default
				row.hide_button:Enable()
			else
				row.default_button:Enable()
				row.hide_button:Disable() -- can't hide a custom note, only default/remove it
			end
		else
			row:Hide()
		end
	end
	
	WHODIS_NS.settings_frame.note_grid.prev_button:Enable()
	WHODIS_NS.settings_frame.note_grid.next_button:Enable()
	
	if page_num == 1 then
		WHODIS_NS.settings_frame.note_grid.prev_button:Disable()
	end
	
	if page_num == num_pages then
		WHODIS_NS.settings_frame.note_grid.next_button:Disable()
	end
	
	WHODIS_NS.settings_frame.note_grid.page_num_label:SetText(tostring(page_num) .. "/" .. tostring(num_pages))
end


-- Settings frame must created in a function as its children rely on data structures not present until after the addon initialises
function WHODIS_NS.create_settings_frame()

	local display_name = "Who Dis" -- ADDON_NAME is not formatted with spaces

	local settings_frame = CreateFrame("Frame")
	settings_frame.name = display_name
	
	local x_offset = 20
	local y_offset = -10
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
	
	--local note_setter_anchor = whodis_create_note_setter(settings_frame, text_opt_anchor, y_section_padding)
	
	--local note_list_anchor = whodis_create_note_list(settings_frame, note_setter_anchor, y_section_padding)
	
	--local test_note_row = whodis_create_note_row(settings_frame, note_setter_anchor, y_section_padding)
	
	settings_frame.note_grid = whodis_create_note_grid(settings_frame, text_opt_anchor, y_section_padding)
	
	InterfaceOptions_AddCategory(settings_frame)
	
	WHODIS_NS.settings_frame = settings_frame
	
	WHODIS_NS.update_settings_note_grid(1, 10)
end

function WHODIS_NS.open_settings_frame()

	-- https://github.com/Stanzilla/WoWUIBugs/issues/89
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.settings_frame)
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.settings_frame) 
	WHODIS_NS.settings_frame:Hide()
	WHODIS_NS.settings_frame:Show() -- required to get lists to rebuild, open to category doesn't seem to trigger OnShow
end

