xorlib.Dependency("xorlib/networking/rpc", "sh_registry.lua")

x.RPCRegistry = x.RPCRegistry or x.Set()

function x.RPCIsRegistered(functionPath)
	return x.RPCRegistry:Has(functionPath)
end

function x.RPCIndex(functionPath)
	return x.RPCRegistry:Index(functionPath)
end

function x.RPCEnsureRegistered(functionPath)
	if x.RPCIsRegistered(functionPath) then return end

	local index = x.RPCRegistry:Insert(functionPath)

	net.Start("xorlib_rpc_register")
	x.NetWriteRPCRegister(functionPath, index)
	net.Broadcast()
end

function x.RPCSendRegistered(target)
	for index, functionPath in ipairs(x.RPCRegistry.Values) do
		net.Start("xorlib_rpc_register")
		x.NetWriteRPCRegister(functionPath, index)
		net.Send(target)
	end
end

hook.Add(
	"PlayerReady",
	"xorlib_rpc_send",
	x.RPCSendRegistered,
	HOOK_MONITOR_HIGH
)
