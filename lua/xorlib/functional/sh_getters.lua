xorlib.Dependency("xorlib/assert", "sh_assert.lua")

local debug_getinfo = debug.getinfo
local explode       = string.Explode

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

    return (info.name or "<unknown>") .. ":" .. info.source .. ":" .. info.linedefined
end

local allowedParseResult = {
    ["table"]    = true,
    ["function"] = true
}

function x.IndexGlobalFunction(functionPath)
    local keys = explode(".", functionPath)
    local outputFunction = _G

    for i = 1, #keys do
        x.Assert(type(outputFunction) == "table",
                 "table expected. Last index is %s",
                 keys[i - 1])

        local key = keys[i]

        outputFunction = outputFunction[key]

        x.Assert(allowedParseResult[type(outputFunction)],
                 "table or function expected. Index: %s",
                 key)
    end

    return outputFunction
end
