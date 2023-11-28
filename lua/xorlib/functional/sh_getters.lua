xorlib.Dependency("xorlib/assert", "sh_assert.lua")

local debug_getinfo  = debug.getinfo
local string_Explode = string.Explode
local type           = type

local _R = debug.getregistry()

function x.Meta(meta, name)
    return _R[meta][name]
end

function x.Callee(addLevel, flags)
    if addLevel then
        -- make level relative to callee

        addLevel = addLevel - 1
    else
        addLevel = 1
    end

    addLevel = addLevel + 1

    return debug_getinfo(addLevel, flags)
end

local UNKNOWN_SOURCE = {
    source = "<unknown>",
    linedefined = -1
}

function x.CalleePath(addLevel)
    addLevel = (addLevel or 1) + 1

    local info = debug_getinfo(addLevel, "Sn") or UNKNOWN_SOURCE

    return (info.name or "<unknown>") .. ":" ..
           info.source .. ":" ..
           info.linedefined
end

function x.Index(tbl, path, filterTypes, allowNil)
    local keys   = string_Explode(".", path)
    local output = tbl or _G

    for i = 1, #keys do
        x.Assert(type(output) == "table",
                 "Table expected. Last index is %s",
                 tostring(keys[i - 1]))

        local key = keys[i]

        output = output[key]

        local outputType = type(output)

        if filterTypes and not filterTypes[outputType] then
            if allowNil then
                return nil
            end

            x.Error("One of %s types expected, but got \"%s\". Index: %s",
                    outputType,
                    key)
        end
    end

    return output
end

function x.NewIndex(tbl, path, value)
    local keys = string_Explode(".", path)

    tbl = tbl or _G

    for i = 1, #keys - 1 do
        x.Assert(type(tbl) == "table",
                 "Table expected. Last index is %s",
                 tostring(keys[i - 1]))

        local key = keys[i]

        tbl = tbl[key]
    end

    local lastKey = keys[#keys]

    tbl[lastKey] = value
end

local indexFunctionFilter = {
    ["function"] = true
}

function x.IndexGlobalFunction(functionPath, allowNil)
    return x.Index(nil, functionPath, indexFunctionFilter, allowNil)
end
