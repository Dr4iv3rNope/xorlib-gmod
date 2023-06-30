xorlib.Dependency("xorlib/assert")
xorlib.Dependency("xorlib/networking", "sh_vaargs.lua")
xorlib.Dependency("xorlib/networking/rpc", "sv_registry.lua")

util.AddNetworkString("xorlib_rpc")
util.AddNetworkString("xorlib_rpc_register")

function x.NetWriteRPC(functionPath, ...)
	local id = x.RPCIndex(functionPath)

	x.Assert(id, "RPC function \"%s\" not registered!", functionPath)

	net.WriteUInt(id, 32)
	x.NetWriteVaargs(...)
end

function x.NetWriteRPCRegister(functionPath, id)
	net.WriteString(functionPath)
	net.WriteUInt(id, 32)
end
