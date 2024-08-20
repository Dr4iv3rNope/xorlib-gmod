xorlib.Dependency("xorlib/assert")
xorlib.Dependency("xorlib/networking", "sh_vaargs.lua")
xorlib.Dependency("xorlib/networking/rpc", "cl_registry.lua")

net.Receive("xorlib_rpc", function()
    local id             = net.ReadUInt(32)
    local outputFunction = x.RPCRegistry[id]

    x.Assert(outputFunction, "Unknown RPC function (id: %d)", id)

    outputFunction(x.NetReadVaargsUnpacked())
end)
