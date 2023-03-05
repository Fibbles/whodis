-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...



-- Utility

-- convert first char to upper case
local function first_to_upper(str)
    return str:sub(1,1):upper() .. str:sub(2)
end

WHODIS_NS.first_to_upper = first_to_upper


-- format string to it is all lower case except for the first char
local function format_name(str)
	return first_to_upper(str:lower())
end

WHODIS_NS.format_name = format_name


-- as above but with the current realm name attached, e.g. Name-RealmName
local function format_name_current_realm(str)
	local realm = GetRealmName():gsub("%s+", "") -- remove spaces for multiword realm names
	return format_name(str) .. "-" .. realm
end

WHODIS_NS.format_name_current_realm = format_name_current_realm


-- check if a character name has the server name attached
local function name_has_realm(str)
	return string.find(str, "%-")
end

WHODIS_NS.name_has_realm = name_has_realm


-- trim whitespace from the beginning and end of a string
local function trim(str)
   return str:match "^%s*(.-)%s*$"
end

WHODIS_NS.trim = trim


local function str_to_bool(str)

	if str then
			
		local str_low = str:lower()
	
		if str_low == "true" or str == "1" then
			return true
		elseif str_low == "false" or str == "0" then
			return false
		end
	end
	
	return nil
end

WHODIS_NS.str_to_bool = str_to_bool


local function split_first_word_from_str(str)

	-- trim any leading white space to work around edge cases
	-- without this a string of "  foo" ends up with both word and remainder being "foo"
	local local_str = trim(str)

	local word = local_str:match("%S+")

	local remainder = local_str:sub(word:len() + 2)
	
	-- get rid of leading any white space
	-- using an offset of 2 in sub (above) is not enough as there may be multiple spaces between the first and next word
	remainder = trim(remainder)
	
	return word, remainder
end

WHODIS_NS.split_first_word_from_str = split_first_word_from_str


local function split_all_words_from_str(str)

	local word_array = {}
	
	for word in str:gmatch("%S+") do
		table.insert(word_array, word)
	end
	
	return word_array
end

WHODIS_NS.split_all_words_from_str = split_all_words_from_str


local function strip_colour_codes_from_str(str)

	str = str:gsub("|c%x%x%x%x%x%x%x%x", "" )
	str = str:gsub("|r", "" )
	
	return str
end

WHODIS_NS.strip_colour_codes_from_str = strip_colour_codes_from_str