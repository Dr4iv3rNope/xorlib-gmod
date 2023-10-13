xorlib.Dependency("xorlib/networking/rpc", "cl_functions.lua")

x.RPCRegistry = x.RPCRegistry or {}

function x.RPCRegister(functionPath, id)
    local outputFunction = x.RPCFindFunction(functionPath)

    x.RPCRegistry[id] = outputFunction
end

net.Receive("xorlib_rpc_register", function()
    local functionPath = net.ReadString()
    local id = net.ReadUInt(32)

    x.RPCRegister(functionPath, id)
end)
