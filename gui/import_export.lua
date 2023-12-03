-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- GUI Page For Importing And Exporting The Character DB

function WHODIS_NS.create_gui_import_frame(parent_frame, x_offset, y_offset, y_section_padding)

	local gui_import_frame = CreateFrame("Frame")
	gui_import_frame.name = "Import / Export"
	gui_import_frame.parent = parent_frame.name
		
	local title_header = WHODIS_NS.create_gui_title_header(gui_import_frame, x_offset, y_section_padding)

	local edit_area = CreateFrame("Frame", nil, gui_import_frame)
	edit_area:SetPoint("TOPLEFT", title_header, "BOTTOMLEFT", 0, y_section_padding)
	--scrollFrame:SetPoint("TOPLEFT", 3, -4)
	edit_area:SetPoint("BOTTOMRIGHT", -27, 4)


	local sf = CreateFrame("ScrollFrame", nil, edit_area, "UIPanelScrollFrameTemplate")
	sf:SetPoint("LEFT", 16, 0)
	sf:SetPoint("RIGHT", -32, 0)
	sf:SetPoint("TOP", 0, -16)
	sf:SetPoint("BOTTOM", 0, 16)
	
	-- EditBox
	local eb = CreateFrame("EditBox", nil, sf)
	eb:SetSize(sf:GetSize())
	eb:SetMultiLine(true)
	eb:SetAutoFocus(false) -- dont automatically focus
	eb:SetFontObject("ChatFontNormal")
	eb:SetScript("OnEscapePressed", function() gui_import_frame:Hide() end)
	sf:SetScrollChild(eb)

	eb:SetText("Some Note")
	eb:Show()


	--local eb = CreateFrame("ScrollFrame", nil, gui_import_frame, "InputScrollFrameTemplate")


	--eb:SetSize(600, 600)
	--eb:SetAutoFocus(false)
	--eb:SetMultiLine(true)
	--eb:SetPoint("TOPLEFT", title_header, "BOTTOMLEFT", 0, y_section_padding)
	--eb:SetText("Some Note")
	--eb:SetCursorPosition(0)

--[[
	local scrollArea = CreateFrame("ScrollFrame", nil, gui_import_frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", gui_import_frame, "TOPLEFT", 8, -5)
	scrollArea:SetPoint("BOTTOMRIGHT", gui_import_frame, "BOTTOMRIGHT", -30, 5)

	local editBox = CreateFrame("EditBox", nil, gui_import_frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(620)
	editBox:SetHeight(495)
	--editBox:SetScript("OnEscapePressed", function(f) f:GetParent():GetParent():Hide() f:SetText("") end)
	]]--
--[[
			-- ScrollFrame
			local sf = CreateFrame("ScrollFrame", nil, gui_import_frame, "UIPanelScrollFrameTemplate")
			--sf:SetPoint("LEFT", 16, 0)
			--sf:SetPoint("RIGHT", -32, 0)
			--sf:SetPoint("TOP", 0, -16)
			--sf:SetPoint("BOTTOM", 0, 32)
			
			-- EditBox
			local eb = CreateFrame("EditBox", nil, sf)
			eb:SetSize(sf:GetSize())
			eb:SetMultiLine(true)
			eb:SetAutoFocus(false) -- dont automatically focus
			eb:SetFontObject("ChatFontNormal")
			--eb:SetScript("OnEscapePressed", function() f:Hide() end)
			sf:SetScrollChild(eb)

			eb:SetText("hello there")

			eb:Show()
]]--
	--editBox:Show()

	--local panel = CreateFrame("Frame")
--panel.name = "MyAddOn"
--InterfaceOptions_AddCategory(panel)
--[[
-- Create the scrolling parent frame and size it to fit inside the texture
local scrollFrame = CreateFrame("ScrollFrame", nil, gui_import_frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 3, -4)
scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)

-- Create the scrolling child frame, set its width to fit, and give it an arbitrary minimum height (such as 1)
local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth()-18)
scrollChild:SetHeight(1) 

-- Add widgets to the scrolling child frame as desired
local title = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText("MyAddOn")

local footer = scrollChild:CreateFontString("ARTWORK", nil, "GameFontNormal")
footer:SetPoint("TOP", 0, -5000)
footer:SetText("This is 5000 below the top, so the scrollChild automatically expanded.")
	]]--




	InterfaceOptions_AddCategory(gui_import_frame)

	--gui_import_frame:Show()
	
	return gui_import_frame
end

--[[
function WHODIS_NS.KethoEditBox_Show(text)
	if not KethoEditBox then
		local f = CreateFrame("Frame", "KethoEditBox", UIParent, "DialogBoxFrame")
		f:SetPoint("CENTER")
		f:SetSize(600, 500)
		
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
			edgeSize = 16,
			insets = { left = 8, right = 6, top = 8, bottom = 8 },
		})
		f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
		
		-- Movable
		f:SetMovable(true)
		f:SetClampedToScreen(true)
		f:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				self:StartMoving()
			end
		end)
		f:SetScript("OnMouseUp", f.StopMovingOrSizing)
		
		-- ScrollFrame
		local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT", 16, 0)
		sf:SetPoint("RIGHT", -32, 0)
		sf:SetPoint("TOP", 0, -16)
		sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
		
		-- EditBox
		local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
		eb:SetSize(sf:GetSize())
		eb:SetMultiLine(true)
		eb:SetAutoFocus(false) -- dont automatically focus
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() f:Hide() end)
		sf:SetScrollChild(eb)
		
		-- Resizable
		f:SetResizable(true)
		--f:SetMinResize(150, 100)
		
		local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)
		
		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
		
		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				f:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			eb:SetWidth(sf:GetWidth())
		end)
		f:Show()
	end
	
	if text then
		KethoEditBoxEditBox:SetText(text)
	end
	KethoEditBox:Show()
end
]]--