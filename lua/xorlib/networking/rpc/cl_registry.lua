xorlib.Dependency("xorlib/networking/rpc", "cl_functions.lua")
xorlib.Dependency("xorlib/functional",     "sh_getters.lua")

x.RPCRegistry = x.RPCRegistry or {}

function x.RPCRegister(functionPath, id)
    local outputFunction = x.Index(nil, functionPath)
    local outputFunctionType = type(outputFunction)

    x.Assert(outputFunctionType == "function",
             "Tried to register function \"%s\", but got type %s",
             functionPath,
             outputFunctionType)

    x.RPCRegistry[id] = outputFunction
end

net.Receive("xorlib_rpc_register", function()
    local functionPath = net.ReadString()
    local id = net.ReadUInt(32)

    x.RPCRegister(functionPath, id)
end)
