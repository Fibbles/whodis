-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- GUI Addon Main Page

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
		WHODIS_NS.SLASH["set"].func((name_eb:GetText() or "") .. " " .. (note_eb:GetText() or ""))
		
		name_eb:ClearFocus()
		name_eb:SetText("")
		note_eb:ClearFocus()
		note_eb:SetText("")
		
		WHODIS_NS.update_gui_note_grid(parent_frame, parent_frame.current_page)
	end
	
	note_eb:SetScript("OnEnterPressed", note_setter)

		
	local btn = CreateFrame("Button", nil, parent_frame, "UIPanelButtonTemplate")
	btn:SetPoint("LEFT", note_eb, "RIGHT", x_padding, 0)
	btn:SetText("Set")
	btn:SetWidth(40)
	btn.tooltipText = WHODIS_NS.SLASH["set"].help
	
	btn:SetScript("OnClick", note_setter)

	return name_eb
end


local function whodis_create_note_row(parent_frame, anchor_frame, y_offset, num_rows)
	
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
		self:SetText(self.read_only_text)
		self:SetCursorPosition(0)
	end
		
	row_frame.note_eb:SetScript("OnEscapePressed", cancel_edit)
	
	
	local function note_setter(self)
		row_frame.note_eb:ClearFocus()
		
		local name = row_frame.name_label:GetText()
		local note = row_frame.note_eb:GetText()
		WHODIS_NS.SLASH["set"].func((name or "") .. " " .. (note or ""))
		
		WHODIS_NS.update_gui_note_grid(parent_frame, parent_frame.current_page)
	end
	
	row_frame.note_eb:SetScript("OnEnterPressed", note_setter)

		
	row_frame.set_button = CreateFrame("Button", nil, row_frame, "UIPanelButtonTemplate")
	row_frame.set_button:SetPoint("LEFT", row_frame.note_eb, "RIGHT", x_padding, 0)
	row_frame.set_button:SetText("Set")
	row_frame.set_button:SetWidth(40)
	row_frame.set_button:SetScript("OnClick", note_setter)
	row_frame.set_button.tooltipText = WHODIS_NS.SLASH["set"].help
	
	row_frame.default_button = CreateFrame("Button", nil, row_frame, "UIPanelButtonTemplate")
	row_frame.default_button:SetPoint("LEFT", row_frame.set_button, "RIGHT", 0, 0)
	row_frame.default_button:SetText("Default")
	row_frame.default_button:SetWidth(60)
	row_frame.default_button.tooltipText = WHODIS_NS.SLASH["default"].help
	
	local function note_default(self)
		row_frame.note_eb:ClearFocus()
		
		local name = row_frame.name_label:GetText()
		WHODIS_NS.SLASH["default"].func(name or "")
		
		WHODIS_NS.update_gui_note_grid(parent_frame, parent_frame.current_page)
	end
	
	row_frame.default_button:SetScript("OnClick", note_default)

	row_frame.hide_button = CreateFrame("Button", nil, row_frame, "UIPanelButtonTemplate")
	row_frame.hide_button:SetPoint("LEFT", row_frame.default_button, "RIGHT", 0, 0)
	row_frame.hide_button:SetText("Hide")
	row_frame.hide_button:SetWidth(40)
	row_frame.hide_button.tooltipText = WHODIS_NS.SLASH["hide"].help
	
	local function note_hide(self)
		row_frame.note_eb:ClearFocus()
		
		local name = row_frame.name_label:GetText()
		WHODIS_NS.SLASH["hide"].func(name or "")
		
		WHODIS_NS.update_gui_note_grid(parent_frame, parent_frame.current_page)
	end
	
	row_frame.hide_button:SetScript("OnClick", note_hide)

	return row_frame
end

local function whodis_create_note_grid(parent_frame, anchor_frame, y_offset, num_rows)

	local x_padding = 10
	local grid_width = 600
	local grid_height = 200
	
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
	
	grid_frame.page_size = num_rows
	
	for iii = 1, num_rows do
		local current_row = whodis_create_note_row(grid_frame, last_anchor, 0)
		last_anchor = current_row
		table.insert(grid_frame.rows, current_row)
	end


	grid_frame.page_num_label = grid_frame:CreateFontString(nil , "BORDER", "GameFontNormal")
	grid_frame.page_num_label:SetJustifyH("CENTER")
	grid_frame.page_num_label:SetPoint("TOP", last_anchor, "BOTTOM", 0, -15)
	grid_frame.page_num_label:SetText("Page Num")
	grid_frame.page_num_label:SetWidth(80)
	
	grid_frame.prev_button = CreateFrame("Button", nil, grid_frame, "UIPanelButtonTemplate")
	grid_frame.prev_button:SetPoint("RIGHT", grid_frame.page_num_label, "LEFT", 0, 0)
	grid_frame.prev_button:SetText("Previous")
	grid_frame.prev_button:SetWidth(80)
	
	local function prev_page(self)
		WHODIS_NS.update_gui_note_grid(self:GetParent(), self:GetParent().current_page - 1)
	end
	grid_frame.prev_button:SetScript("OnClick", prev_page)

	grid_frame.next_button = CreateFrame("Button", nil, grid_frame, "UIPanelButtonTemplate")
	grid_frame.next_button:SetPoint("LEFT", grid_frame.page_num_label, "RIGHT", 0, 0)
	grid_frame.next_button:SetText("Next")
	grid_frame.next_button:SetWidth(80)
	
	local function next_page(self)
		WHODIS_NS.update_gui_note_grid(self:GetParent(), self:GetParent().current_page + 1)
	end
	grid_frame.next_button:SetScript("OnClick", next_page)
	
	return grid_frame
end

function WHODIS_NS.update_gui_note_grid(grid_frame, page_num)
	
	-- sort the roster alpabetically
	
	local names = {}
	for char_name, _ in pairs(WHODIS_ADDON_DATA_CHAR.ROSTER) do
		table.insert(names, char_name)
	end
	table.sort(names)
	
	local num_names = table.getn(names)
	grid_frame.num_names = num_names
	
	-- page size is set when the grid is created and shouldn't be altered after
	local page_size = grid_frame.page_size
	
	local num_pages = math.ceil(num_names / page_size)
	grid_frame.num_pages = num_pages
	
	page_num = math.max(1, math.min(page_num, num_pages))
	grid_frame.current_page = page_num
	
	-- modulo with 1 based inclusive indexing really sucks
	local begin_index = math.min(((page_num - 1) * page_size) + 1, num_names)
	local end_index = math.min(((page_num - 1) * page_size) + page_size, num_names)
	
	for iii = begin_index, begin_index + page_size - 1 do
		
		local row_num = ((iii - 1) % page_size) + 1
		
		local row = grid_frame.rows[row_num]
			
		if iii <= end_index then
			
			row:Show()
			
			row.name_label:SetText(names[iii])
			
			local rank, _, note = unpack(WHODIS_ADDON_DATA_CHAR.ROSTER[names[iii]])
			
			row.note_eb:SetText(note)
			row.note_eb.read_only_text = note
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
	
	grid_frame.prev_button:Enable()
	grid_frame.next_button:Enable()
	
	if page_num == 1 then
		grid_frame.prev_button:Disable()
	end
	
	if page_num == num_pages then
		grid_frame.next_button:Disable()
	end
	
	grid_frame.page_num_label:SetText(tostring(page_num) .. "/" .. tostring(num_pages))
end

function WHODIS_NS.create_gui_title_header(parent_frame, x_offset, y_offset)

	local header_frame = CreateFrame("Frame", nil, parent_frame)
	header_frame:SetPoint("TOPLEFT", parent_frame, "TOPLEFT", x_offset, y_offset)
	header_frame:SetSize(24, 24)

	local logo_tex = header_frame:CreateTexture(nil, "BORDER", nil)
	logo_tex:SetTexture([[Interface/Addons/WhoDis/resources/whodis_logo_64.blp]])
	logo_tex:SetAllPoints()
		
	local title_label = header_frame:CreateFontString(nil , "BORDER", "GameFontNormalLarge")
	title_label:SetJustifyH("LEFT")
	title_label:SetPoint("LEFT", logo_tex, "RIGHT", 10, 0)
	title_label:SetText("Who Dis") -- ADDON_NAME is not formatted with spaces
	
	return header_frame
end

local function whodis_create_gui_main_frame(parent_frame, x_offset, y_offset, y_section_padding)

	local gui_main_frame = CreateFrame("Frame")
	gui_main_frame.name = "Who Dis"
	
	local title_header = WHODIS_NS.create_gui_title_header(gui_main_frame, x_offset, y_section_padding)
		
	local note_grid_page_size = 14
		
	gui_main_frame.note_grid = whodis_create_note_grid(gui_main_frame, title_header, y_section_padding, note_grid_page_size)
	
	--populate the grid
	WHODIS_NS.update_gui_note_grid(gui_main_frame.note_grid, 1)
	
	InterfaceOptions_AddCategory(gui_main_frame)
	
	return gui_main_frame
end

-- Settings frame must created in a function as its children rely on data structures not present until after the addon initialises
function WHODIS_NS.create_gui_frames()

	local x_offset = 20
	local y_offset = -10
	local y_section_padding = -20
	
	WHODIS_NS.gui_main_frame = whodis_create_gui_main_frame(nil, x_offset, y_offset, y_section_padding)
	
	WHODIS_NS.gui_settings_frame = WHODIS_NS.create_gui_settings_frame(WHODIS_NS.gui_main_frame, x_offset, y_offset, y_section_padding)
end

function WHODIS_NS.open_gui_frame()

	-- https://github.com/Stanzilla/WoWUIBugs/issues/89
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.gui_main_frame)
	InterfaceOptionsFrame_OpenToCategory(WHODIS_NS.gui_main_frame) 
	WHODIS_NS.gui_main_frame:Hide()
	WHODIS_NS.gui_main_frame:Show() -- required to get lists to rebuild, open to category doesn't seem to trigger OnShow
end

