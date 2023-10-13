xorlib.Dependency("xorlib/networking/rpc", "sv_network.lua")
xorlib.Dependency("xorlib/networking/rpc", "sv_registry.lua")

function x.RPCOnly(receivers, functionPath, ...)
    x.RPCEnsureRegistered(functionPath)

    net.Start("xorlib_rpc")
    x.NetWriteRPC(functionPath, ...)
    net.Send(receivers)
end

function x.RPCOmit(exclude, functionPath, ...)
    x.RPCEnsureRegistered(functionPath)

    net.Start("xorlib_rpc")
    x.NetWriteRPC(functionPath, ...)
    net.Omit(exclude)
end

function x.RPCAll(functionPath, ...)
    x.RPCEnsureRegistered(functionPath)

    net.Start("xorlib_rpc")
    x.NetWriteRPC(functionPath, ...)
    net.Broadcast()
end

local PLAYER = FindMetaTable("Player")
PLAYER.RPC = x.RPCOnly
