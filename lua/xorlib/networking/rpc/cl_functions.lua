xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Error

local allowedParseResult = {
	["table"] = true,
	["function"] = true
}

function x.RPCFindFunction(functionPath)
	local keys = string.Explode(".", functionPath)
	local outputFunction = _G

	for i = 1, #keys do
		if type(outputFunction) ~= "table" then
			x.Error("table expected. Last index is %s", keys[i - 1])
		end

		local key = keys[i]
		outputFunction = outputFunction[key]

		if not allowedParseResult[type(outputFunction)] then
			x.Error("table or function expected. Index: %s", key)
		end
	end

	return outputFunction
end
