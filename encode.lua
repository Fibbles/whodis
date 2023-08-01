-- Addon Lua Namespace
local ADDON_NAME, WHODIS_NS = ...

-- Functions for encoding and decoding data

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local LibSerialize = LibStub:GetLibrary("LibSerialize")


-- Encoding

local function whodis_compress_internal(data)

    local serialized = LibSerialize:Serialize(data)
    return LibDeflate:CompressDeflate(serialized)
end

function WHODIS_NS.encode_for_print(data)

    local compressed = whodis_compress_internal(data)
    return LibDeflate:EncodeForPrint(compressed)
end


function WHODIS_NS.encode_for_addon_channel(data)

    local compressed = whodis_compress_internal(data)
    return LibDeflate:EncodeForWoWAddonChannel(compressed)
end


function WHODIS_NS.encode_for_chat_channel(data)

    local compressed = whodis_compress_internal(data)
    return LibDeflate:EncodeForWoWChatChannel(compressed)
end


-- Decoding

local function whodis_decompress_internal(decoded_data)

    if not decoded_data then
        return nil
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded_data)

    if not decompressed then
        return nil
    end

    local success, data = LibSerialize:Deserialize(decompressed)

    if success then
        return data
    else
        return nil
    end
end


function WHODIS_NS.decode_for_print(encoded_data)

    if not encoded_data then
        return nil
    end

    local decoded = LibDeflate:DecodeForPrint(encoded_data)

    return whodis_decompress_internal(decoded)
end


function WHODIS_NS.decode_for_addon_channel(encoded_data)

    if not encoded_data then
        return nil
    end

    local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded_data)

    return whodis_decompress_internal(decoded)
end


function WHODIS_NS.decode_for_chat_channel(encoded_data)

    if not encoded_data then
        return nil
    end

    local decoded = LibDeflate:DecodeForWoWChatChannel(encoded_data)

    return whodis_decompress_internal(decoded)
end


-- Tests

local function whodis_test_encode(str)
    local output = WHODIS_NS.encode_for_print(str)
    print(output)
end

WHODIS_NS.SLASH["test-encode"] = {
    func = whodis_test_encode,
    dev = true,
    help = "Compress and encode a string."
}


local function whodis_test_decode(str)
    local output = WHODIS_NS.decode_for_print(str)
    print(output)
end

WHODIS_NS.SLASH["test-decode"] = {
    func = whodis_test_decode,
    dev = true,
    help = "Decompress and decode a string."
}