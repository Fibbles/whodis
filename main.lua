-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Initialisation

WHODIS_NS.INITIALISED = false

local function whodis_initialiser()

	-- Our saved variables are ready at this point. If there are none, variables will be nil.
	
	if not WHODIS_ADDON_DATA then
		WHODIS_ADDON_DATA = { }
	end
	
	-- Overides are global across all characters and realms
	if not WHODIS_ADDON_DATA.OVERRIDES then
		WHODIS_ADDON_DATA.OVERRIDES = { }
	end
	
	if WHODIS_ADDON_DATA.COLOUR_NAMES == nil then
		WHODIS_ADDON_DATA.COLOUR_NAMES = true
	end
	
	if WHODIS_ADDON_DATA.COLOUR_BRACKETS == nil then
		WHODIS_ADDON_DATA.COLOUR_BRACKETS = true
	end
	
	if WHODIS_ADDON_DATA.HIDE_GREETING == nil then
		WHODIS_ADDON_DATA.HIDE_GREETING = false
	end
	
	if WHODIS_ADDON_DATA.NOTE_FILTER == nil then
		WHODIS_ADDON_DATA.NOTE_FILTER = true
	end
	
	if not WHODIS_ADDON_DATA_CHAR then
		WHODIS_ADDON_DATA_CHAR = { }
	end
	
	-- Rosters are guild specific so are dealt with per character
	if not WHODIS_ADDON_DATA_CHAR.ROSTER then
		WHODIS_ADDON_DATA_CHAR.ROSTER = { }
	end
	
	--[[
	if not WHODIS_ADDON_DATA_CHAR.ALT_RANK then
		WHODIS_ADDON_DATA_CHAR.ALT_RANK = "alt"
	end
	]]--
	
	-- ensure the local cache is populated, triggers a GUILD_ROSTER_UPDATE
	-- wont do anything if another addon called this in the last 10s
	-- this may be an issue on the addon's first run 
	-- we will eventually have the cached roster in WHODIS_ADDON_DATA_CHAR as a fallback
	GuildRoster()
	
	WHODIS_NS.register_chat_filters()
	
	WHODIS_NS.create_settings_frame()

	if not WHODIS_ADDON_DATA.HIDE_GREETING then
		local addon_version = GetAddOnMetadata(ADDON_NAME, "Version")
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
			WHODIS_NS.build_roster(WHODIS_ADDON_DATA.HIDE_GREETING)
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
				WHODIS_NS.build_roster(WHODIS_ADDON_DATA.HIDE_GREETING)
			end
			whodis_event_frame:SetScript("OnUpdate", nil)
		end
	end
end

whodis_event_frame:SetScript("OnUpdate", whodis_event_frame.on_update)


