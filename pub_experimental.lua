-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...


-- Experimental commands that are available to users but are not supported and may be removed

if not WHODIS_NS.SLASH then
	WHODIS_NS.SLASH = {}
end

local function whodis_export_roster_as_overrides(remove_string)

	-- move all the guild notes into custom notes, useful if you're switching guilds

	local num_members = GetNumGuildMembers()
	local count = 0
	
	if num_members ~= 0 then 
	
		for iii = 1, num_members do
			local name, rank, _, _, class, _, note = GetGuildRosterInfo(iii)
			
			if note and note ~= '' then						
				-- dont export if a custom note already exists		
				if WHODIS_ADDON_DATA.OVERRIDES[name] == nil then
					
					-- clear the remove_string from the note before saving as an override
					-- useful if your GM formats the notes as 'SomeAltName alt' you can pass ' alt' as the remove_string
					if remove_string and remove_string ~= '' then
						note = WHODIS_NS.trim(gsub(note, remove_string, ""))
					end
					
					--WHODIS_ADDON_DATA.OVERRIDES[name] = whodis_colour_note_with_main_class(note)
					WHODIS_ADDON_DATA.OVERRIDES[name] = note
					count = count + 1
				end
			end
		end
		
		WHODIS_NS.msg_generic("Exported " .. count .. " members in the guild roster.")
	else
		WHODIS_NS.warn_generic("No members in the guild roster. Export cancelled.")
	end
end

WHODIS_NS.SLASH["export-roster"] = {
func = whodis_export_roster_as_overrides,
dev = true,
arg_str = "RemoveString",
help = [[EXPERIMENTAL - MAY HAVE BUGS
Take all guild notes and set them as custom notes (if a custom note doesn't already exist for that character).
Optionally pass a 'RemoveString'. This will be removed from the guild note before exporting.
You may want to use this command if you are changing guilds so that you retain your old guild's character notes.]]
}