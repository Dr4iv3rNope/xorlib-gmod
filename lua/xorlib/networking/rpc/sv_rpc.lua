xorlib.Dependency("xorlib/networking", "sh_vaargs.lua") -- x.NetWriteVaargs

util.AddNetworkString("xorlib_rpc")

function x.RPCOnly(receivers, name, ...)
	net.Start("xorlib_rpc")
	net.WriteString(name)
	x.NetWriteVaargs(...)
	net.Send(receivers)
end

function x.RPCOmit(exclude, name, ...)
	net.Start("xorlib_rpc")
	net.WriteString(name)
	x.NetWriteVaargs(...)
	net.Omit(exclude)
end

function x.RPCAll(name, ...)
	net.Start("xorlib_rpc")
	net.WriteString(name)
	x.NetWriteVaargs(...)
	net.Broadcast()
end

local PLAYER = FindMetaTable("Player")
PLAYER.RPC = x.RPCOnly
