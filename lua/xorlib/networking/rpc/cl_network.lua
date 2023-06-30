xorlib.Dependency("xorlib/assert")
xorlib.Dependency("xorlib/networking", "sh_vaargs.lua")
xorlib.Dependency("xorlib/networking/rpc", "cl_registry.lua")

function x.NetReadRPC()
	local id = net.ReadUInt(32)
	local outputFunction = x.RPCRegistry[id]
	local args = x.NetReadVaargs()

	x.Assert(outputFunction, "Unknown RPC function (id: %d)", id)

	return outputFunction, args
end

net.Receive("xorlib_rpc", function()
	local outputFunction, args = x.NetReadRPC()

	outputFunction(
		args[1], args[2], args[3],
		args[4], args[5], args[6],
		args[7], args[8], args[9]
	)
end)
