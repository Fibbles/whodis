-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Initialisation

WHODIS_NS.INITIALISED = false

local function whodis_setup_account_db(addon_version)

	-- Our saved variables are ready at this point. If there are none, variables will be nil.
	
	-- ACCOUNT WIDE DATABASES
	if not WHODIS_ADDON_DATA then
		WHODIS_ADDON_DATA = { }
	end
	
	if not WHODIS_ADDON_DATA.SETTINGS then
		WHODIS_ADDON_DATA.SETTINGS = { }
	end
	
	
	-- Overides are global across all characters and realms
	if not WHODIS_ADDON_DATA.OVERRIDES then
		WHODIS_ADDON_DATA.OVERRIDES = { }
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


local function whodis_setup_char_db(addon_version)

	-- CHARACTER SPECIFIC DATABASES
	if not WHODIS_ADDON_DATA_CHAR then
		WHODIS_ADDON_DATA_CHAR = { }
	end

	if not WHODIS_ADDON_DATA_CHAR.SETTINGS then
		WHODIS_ADDON_DATA_CHAR.SETTINGS = { }
	end
	
	-- Rosters are guild specific so are dealt with per character
	if not WHODIS_ADDON_DATA_CHAR.ROSTER then
		WHODIS_ADDON_DATA_CHAR.ROSTER = { }
	end
	
	
	local previous_db_ver = tonumber(WHODIS_ADDON_DATA_CHAR.DB_VERSION or 1.0)
	WHODIS_ADDON_DATA_CHAR.DB_VERSION = tonumber(addon_version)
	
	if previous_db_ver < 2.0 then
		-- clean up old settings from 1.x versions of the addon		
		WHODIS_ADDON_DATA_CHAR.ALT_RANK = nil
	end
end


local function whodis_initialiser()

	local addon_version = GetAddOnMetadata(ADDON_NAME, "Version")

	whodis_setup_account_db(addon_version)
	whodis_setup_char_db(addon_version)
	
	-- ensure the local cache is populated, triggers a GUILD_ROSTER_UPDATE
	-- wont do anything if another addon called this in the last 10s
	-- this may be an issue on the addon's first run 
	-- we will eventually have the cached roster in WHODIS_ADDON_DATA_CHAR as a fallback
	GuildRoster()
	
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
whodis_event_frame:RegisterEvent("GUILD_ROSTER_UPDATE")

local function whodis_events(self, event, ...)

	if event == "ADDON_LOADED" then
		local addon = ...
		if addon == ADDON_NAME then 
			whodis_initialiser()
		end 
	elseif WHODIS_NS.INITIALISED and event == "GUILD_ROSTER_UPDATE" then
		if not WHODIS_NS.GUILD_ROSTER_LOADED then
			WHODIS_NS.build_roster(WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING)
		end
		-- GUILD_ROSTER_UPDATE can be triggered 2-3 times every time someone logs in or out
		-- once after log in should be fine, the user can always call /whodis populate to force an update if required
		-- however if the user stays too long on the login screen we get the event but no guild roster

		whodis_event_frame:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

whodis_event_frame:SetScript("OnEvent", whodis_events)

-- the second work around for guild roster updates. try once 30s after log in
-- in theory the roster should have loaded by now
function whodis_event_frame:on_update(since_last_update)

	if WHODIS_NS.INITIALISED then
	
		self.since_last_update = (self.since_last_update or 0) + since_last_update
		
		if (self.since_last_update >= 30) then -- in seconds
			if not WHODIS_NS.GUILD_ROSTER_LOADED then
				GuildRoster()
				WHODIS_NS.build_roster(WHODIS_ADDON_DATA.SETTINGS.HIDE_GREETING)
			end
			whodis_event_frame:SetScript("OnUpdate", nil)
		end
	end
end

whodis_event_frame:SetScript("OnUpdate", whodis_event_frame.on_update)


