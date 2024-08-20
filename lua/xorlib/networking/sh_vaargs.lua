xorlib.Dependency("xorlib/assert", "sh_assert.lua")

local select = select

function x.NetWriteVaargs(...)
    local argc = select("#", ...)

    net.WriteUInt(argc, 8)

    for i = 1, argc do
        local v = select(i, ...)

        net.WriteType(v)
    end
end

-- TODO: deprecated. Use `{ x.NetReadVaargsUnpacked() }`
function x.NetReadVaargs()
    return { x.NetReadVaargsUnpacked() }
end

local function internalNetReadVaargsUnpacked(argc)
    if argc == 0 then return end

    return net.ReadType(), internalNetReadVaargsUnpacked(argc - 1)
end

-- TODO: we should rename it to x.NetReadVaargs in future
function x.NetReadVaargsUnpacked()
    local argc = net.ReadUInt(8)

    return internalNetReadVaargsUnpacked(argc)
end
