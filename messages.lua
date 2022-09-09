-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...

-- Messages and Warnings

local WHODIS_CHAT_PREFIX = "|cFFFFD700Who Dis:|r "

local function whodis_warn_generic(text)
	print(WHODIS_CHAT_PREFIX .. "|cFFFF0000" .. text .. "|r")
end

local function whodis_msg_generic(text)
	print(WHODIS_CHAT_PREFIX .. "|cFFFFFFFF" .. text .. "|r")
end

WHODIS_NS.warn_generic = whodis_warn_generic
WHODIS_NS.msg_generic = whodis_msg_generic



function WHODIS_NS.warn_command()
	whodis_warn_generic("Please pass a valid command. Try '/whodis help' or see the readme for details.")
end



function WHODIS_NS.msg_init(addon_version)
	whodis_msg_generic("v" .. addon_version .. " loaded.")
end



function WHODIS_NS.msg_help()
	
	whodis_msg_generic("The following commands are available:")
	
	print("------")
	
	print([[/whodis set CharName note
-- set a custom note
-- if the player is a guildie this will override the default guild note
-- character name is not case sensitive and will be assumed to be on your realm
-- if you specify the realm then the character name and realm are case sensitive]])

	print("------")

	print([[/whodis hide CharName
-- hide the note for the specified character]])

	print("------")

	print([[/whodis default CharName
-- removes any custom note and displays the default guild note (if there is one)
-- character name is not case sensitive and will be assumed to be on your realm
-- if you specify the realm then the character name and realm are case sensitive]])

	print("------")

	print([[/whodis rank-filter RankName
-- only show notes for guildies with this rank (off by default)
-- if your guild roster is well organised you may only want to display notes against players with rank 'alt'
-- leave RankName blank to disable this filter and show notes for all guildies]])

	print("------")

	print([[/whodis print-rank-filter
-- check what the current rank filter is set to]])

	print("------")

	print([[/whodis note-filter bool
-- if set to true the addon will remove variations of 'alt' and 'main' from the end of guild notes (off by default)
-- true or false]])

	print("------")

	print([[/whodis colour-names bool
-- if the addon can recognise a note as a guild member's name it will colour the note based on their class
-- true or false]])

	print("------")

	print([[/whodis colour-brackets bool
-- colour brackets grey or leave them the same colour as the channel's text
-- true or false]])

	print("------")

	print([[/whodis hide-greeting bool
-- hides addon message from the chat window on load
-- true or false]])

	print("------")

	print([[/whodis print CharName
-- mostly for debugging
-- print info about a specific player on the roster
-- character name is not case sensitive and will be assumed to be on your realm
-- if you specify the realm then the character name and realm are case sensitive]])

	print("------")

	print([[/whodis print-roster
-- mostly for debugging
-- print the roster (guild roster + overrides)
-- essentially this is a list of everyone we will display a note for]])

	print("------")

	print([[/whodis print-overrides
-- mostly for debugging
-- print all overrides, i.e. custom notes]])

	print("------")

	print([[/whodis populate
-- attempt to force an update of the guild roster
-- useful if your guildmaster just set some new guild notes]])

	print("------")

	print([[/whodis delete-everything
-- clear the cached guild roster and all notes
-- be sure you want to call this because once your notes are gone, they can't be recovered]])
	
end
