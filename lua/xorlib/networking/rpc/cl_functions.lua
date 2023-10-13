xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Error

local allowedParseResult = {
    ["table"]    = true,
    ["function"] = true
}

function x.RPCFindFunction(functionPath)
    local keys = string.Explode(".", functionPath)
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
