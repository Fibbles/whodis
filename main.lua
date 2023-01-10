-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Initialisation

WHODIS_NS.INITIALISED = false

local function whodis_setup_db(addon_version)

	-- Our saved variables are ready at this point. If there are none, variables will be nil.
	
	-- ACCOUNT WIDE DATABASES
	if not WHODIS_ADDON_DATA then
		WHODIS_ADDON_DATA = { }
	end
	
	if not WHODIS_ADDON_DATA.SETTINGS then
		WHODIS_ADDON_DATA.SETTINGS = { }
	end
	
	if not WHODIS_ADDON_DATA.SETTINGS then
		WHODIS_ADDON_DATA.SETTINGS = { }
	end
	
	-- New note database that combines characters across all guilds
	if not WHODIS_ADDON_DATA.CHARACTER_DB then
		WHODIS_ADDON_DATA.CHARACTER_DB = { }
	end
	
	
	local previous_db_ver = tonumber(WHODIS_ADDON_DATA.DB_VERSION or 1.0)
	WHODIS_ADDON_DATA.DB_VERSION = tonumber(addon_version)
	
	if previous_db_ver < 2.0 then
		-- clean up old settings from 1.x versions of the addon
		WHODIS_ADDON_DATA.COLOUR_NAMES = nil
		WHODIS_ADDON_DATA.COLOUR_BRACKETS = nil
		WHODIS_ADDON_DATA.HIDE_GREETING = nil
		WHODIS_ADDON_DATA.NOTE_FILTER = nil
	end
		
	if previous_db_ver < 2.1 and WHODIS_ADDON_DATA.OVERRIDES then
		-- strip any colour codes that may have polluted the overrides db
		for key, value in pairs(WHODIS_ADDON_DATA.OVERRIDES) do
			local clean_note = WHODIS_NS.strip_colour_codes_from_str(value)

			if clean_note ~= "" then
				WHODIS_ADDON_DATA.CHARACTER_DB[key] = { override_note = clean_note }
			else
				WHODIS_ADDON_DATA.CHARACTER_DB[key] = { hidden = true }
			end
		end

		WHODIS_ADDON_DATA.OVERRIDES = nil
	end
	
	
	-- Default settings
	if WHODIS_ADDON_DATA.SETTINGS.COLOUR_NAMES == nil then
		WHODIS_ADDON_DATA.SETTINGS.COLOUR_NAMES = true
	end
	
	if WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS == nil then
		WHODIS_ADDON_DATA.SETTINGS.COLOUR_BRACKETS = true
	end
	
	if WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING == nil then
		WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING = false
	end
	
	if WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER == nil then
		WHODIS_ADDON_DATA.SETTINGS.NOTE_FILTER = true
	end
end

local function whodis_delayed_build_roster()

	if not WHODIS_NS.GUILD_ROSTER_LOADED then
		WHODIS_NS.build_roster(WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING)
	end
end

local function whodis_initialiser()

	local addon_version = GetAddOnMetadata(ADDON_NAME, "Version")

	whodis_setup_db(addon_version)
	
	-- may not actually build guild notes if we have just logged in but it is required to make cached notes available immediately
	WHODIS_NS.build_roster(true)

	-- try again 30 seconds later, in theory guild notes should have loaded by this point
	C_Timer.After(30, whodis_delayed_build_roster)
	
	WHODIS_NS.register_chat_filters()
	
	WHODIS_NS.create_gui_frames()

	if not WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING then
		WHODIS_NS.msg_init(addon_version)
	end
	
	WHODIS_NS.INITIALISED = true
end



-- Event Handling

local whodis_event_frame = CreateFrame("FRAME"); -- Need a frame to respond to events
whodis_event_frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded

local function whodis_events(self, event, ...)

	if event == "ADDON_LOADED" then

		local addon = ...

		if addon == ADDON_NAME then 
			whodis_initialiser()
			whodis_event_frame:UnregisterEvent("ADDON_LOADED")
		end 
	end
end

whodis_event_frame:SetScript("OnEvent", whodis_events)


