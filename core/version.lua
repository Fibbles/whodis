-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...

-- Version number handling

if not WHODIS_NS.VERSION then
    WHODIS_NS.VERSION = {}
end


function WHODIS_NS.VERSION.update_version_number()

	WHODIS_NS.VERSION.CURRENT = GetAddOnMetadata(ADDON_NAME, "Version") or "1.0.0"
	WHODIS_NS.VERSION.PREVIOUS = tostring(WHODIS_ADDON_DATA.DB_VERSION) or "1.0.0"

	-- DB is always watermarked with the current version number of the addon if it is higher
    -- or_equal allows default 1.0.0 to pass through for cases where no version info exists
    if WHODIS_NS.VERSION.is_greater_or_equal(WHODIS_NS.VERSION.CURRENT, WHODIS_NS.VERSION.PREVIOUS) then
        WHODIS_ADDON_DATA.DB_VERSION = WHODIS_NS.VERSION.CURRENT
    end
end


-- semantic version numbers must be broken into individual floats for compasion so that 2.10.0 compares as greater than 2.9.0 etc
local function whodis_split_semantic_string(version_str)

	if not version_str then
		return 0, 0, 0
	end

	local major, minor, patch = strsplit(".", version_str)

	major = tonumber(major) or 0
	minor = tonumber(minor) or 0
    patch = tonumber(patch) or 0

	return major, minor, patch
end


local function whodis_version_is_greater(major, minor, patch, other_major, other_minor, other_patch)

    return  (major > other_major) or 
            (major == other_major and minor > other_minor) or 
            (major == other_major and minor == other_minor and patch > other_patch)
end

local function whodis_version_is_equal(major, minor, patch, other_major, other_minor, other_patch)

    return (major == other_major) and (minor == other_minor) and (patch == other_patch)
end

local function whodis_version_is_less(major, minor, patch, other_major, other_minor, other_patch)

    return  (major < other_major) or 
            (major == other_major and minor < other_minor) or 
            (major == other_major and minor == other_minor and patch < other_patch)
end

local function whodis_version_is_greater_or_equal(major, minor, patch, other_major, other_minor, other_patch)

    return not whodis_version_is_less(major, minor, patch, other_major, other_minor, other_patch)
end

local function whodis_version_is_less_or_equal(major, minor, patch, other_major, other_minor, other_patch)

    return not whodis_version_is_greater(major, minor, patch, other_major, other_minor, other_patch)
end


local function whodis_float_version_compare(version, other_version, compare_func)

    local major, minor, patch = whodis_split_semantic_string(version)
    local other_major, other_minor, other_patch = whodis_split_semantic_string(other_version)

    return compare_func(major, minor, patch, other_major, other_minor, other_patch)
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