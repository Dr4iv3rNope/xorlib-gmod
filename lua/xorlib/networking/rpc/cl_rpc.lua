xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Error
xorlib.Dependency("xorlib/networking", "sh_vaargs.lua") -- x.NetReadVaargsUnpacked

local type		= type
local explode	= string.Explode

local rpcCache	= {}

local allowedParseResult = {
	["table"] = true,
	["function"] = true
}

local function parseFunctionName(name)
	local cached = rpcCache[name]

	if cached then
		return cached
	end

	local indices = explode(".", name)
	local result = _G

	for i = 1, #indices do
		if type(result) ~= "table" then
			x.Error("table expected. Last index is %s", indices[i - 1])
		end

		local index = indices[i]
		result = result[index]

		if not allowedParseResult[type(result)] then
			x.Error("table or function expected. Index: %s", index)
		end
	end

	rpcCache[name] = result

	return result
end

net.Receive("xorlib_rpc", function()
	local funcName = net.ReadString()
	local func = parseFunctionName(funcName)

	func(x.NetReadVaargsUnpacked())
end)
