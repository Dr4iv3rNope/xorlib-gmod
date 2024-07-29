xorlib.Dependency("xorlib/assert")
xorlib.Dependency("xorlib/networking", "sh_vaargs.lua")
xorlib.Dependency("xorlib/networking/rpc", "cl_registry.lua")

local unpack = unpack

function x.NetReadRPC()
    local id             = net.ReadUInt(32)
    local outputFunction = x.RPCRegistry[id]
    local args           = x.NetReadVaargs()

    x.Assert(outputFunction, "Unknown RPC function (id: %d)", id)

    return outputFunction, args
end

net.Receive("xorlib_rpc", function()
    local outputFunction, args = x.NetReadRPC()

    outputFunction(unpack(args))
end)
