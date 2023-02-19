-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...

-- Version number handling

WHODIS_NS.VERSION = {}


function WHODIS_NS.VERSION.update_version_number()

	-- filter out any nonsense like letters or unsupported major.minor.patch version numbers in the TOC file
	WHODIS_NS.VERSION.CURRENT = tonumber(GetAddOnMetadata(ADDON_NAME, "Version")) or 1.0
	WHODIS_NS.VERSION.PREVIOUS = WHODIS_ADDON_DATA.DB_VERSION or 1.0

	-- DB is always watermarked with the current version number of the addon if it is higher
	WHODIS_ADDON_DATA.DB_VERSION = math.max(WHODIS_NS.VERSION.CURRENT, WHODIS_NS.VERSION.PREVIOUS)
end


-- version numbers must be broken into major.minor so that 2.10 compares as greater than 2.9 etc
local function whodis_convert_to_major_minor(version_float)

	if not version_float then
		return 0, 0
	end

	local version_str = tostring(version_float)

	local major, minor = strsplit(".", version_str)

	major = tonumber(major) or 0
	minor = tonumber(minor) or 0

	return major, minor
end


local function whodis_version_is_greater(major, minor, other_major, other_minor)

    return (major > other_major) or (major == other_major and minor > other_minor)
end

local function whodis_version_is_equal(major, minor, other_major, other_minor)

    return (major == other_major) and (minor == other_minor)
end

local function whodis_version_is_less(major, minor, other_major, other_minor)

    return (major < other_major) or (major == other_major and minor < other_minor)
end

local function whodis_version_is_greater_or_equal(major, minor, other_major, other_minor)

    return whodis_version_is_greater(major, minor, other_major, other_minor) or 
            whodis_version_is_equal(major, minor, other_major, other_minor)
end

local function whodis_version_is_less_or_equal(major, minor, other_major, other_minor)

    return whodis_version_is_less(major, minor, other_major, other_minor) or 
            whodis_version_is_equal(major, minor, other_major, other_minor)
end


local function whodis_float_version_compare(version, other_version, compare_func)

    local major, minor = whodis_convert_to_major_minor(version)
    local other_major, other_minor = whodis_convert_to_major_minor(other_version)

    return compare_func(major, minor, other_major, other_minor)
end


function WHODIS_NS.VERSION.is_greater(version, other_version)

    return whodis_float_version_compare(version, other_version, whodis_version_is_greater)
end

function WHODIS_NS.VERSION.is_equal(version, other_version)
    
    return whodis_float_version_compare(version, other_version, whodis_version_is_equal)
end

function WHODIS_NS.VERSION.is_less(version, other_version)
    
    return whodis_float_version_compare(version, other_version, whodis_version_is_less)
end

function WHODIS_NS.VERSION.is_greater_or_equal(version, other_version)

    return whodis_float_version_compare(version, other_version, whodis_version_is_greater_or_equal)
end

function WHODIS_NS.VERSION.is_less_or_equal(version, other_version)
    
    return whodis_float_version_compare(version, other_version, whodis_version_is_less_or_equal)
end