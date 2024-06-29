xorlib.Dependency("xorlib/assert", "sh_assert.lua")

local unpack = unpack
local select = select

x.NetworkTypesSerializers =
{
    ["nil"] = { TypeID = TYPE_NIL,    Write = function() end  },
    number  = { TypeID = TYPE_NUMBER, Write = net.WriteFloat  },
    boolean = { TypeID = TYPE_BOOL,   Write = net.WriteBool   },
    string  = { TypeID = TYPE_STRING, Write = net.WriteString },
    table   = { TypeID = TYPE_TABLE,  Write = net.WriteTable  },
    Entity  = { TypeID = TYPE_ENTITY, Write = net.WriteEntity },
    Vector  = { TypeID = TYPE_VECTOR, Write = net.WriteVector },
    Angle   = { TypeID = TYPE_ANGLE,  Write = net.WriteAngle  },
    Color   = { TypeID = TYPE_COLOR,  Write = net.WriteColor  }
}

x.NetworkTypesSerializers.Player  = x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.Weapon  = x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.Vehicle = x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.NPC     = x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.NextBot = x.NetworkTypesSerializers.Entity

x.NetworkTypesDeserializers =
{
    [TYPE_NIL]    = function() return nil end,
    [TYPE_NUMBER] = net.ReadFloat,
    [TYPE_BOOL]   = net.ReadBool,
    [TYPE_STRING] = net.ReadString,
    [TYPE_VECTOR] = net.ReadVector,
    [TYPE_ANGLE]  = net.ReadAngle,
    [TYPE_ENTITY] = net.ReadEntity,
    [TYPE_TABLE]  = net.ReadTable,
    [TYPE_COLOR]  = net.ReadColor
}

local serializers   = x.NetworkTypesSerializers
local deserializers = x.NetworkTypesDeserializers

function x.NetWriteVaargs(...)
    local argc = select("#", ...)

    net.WriteUInt(argc, 8)

    for i = 1, argc do
        local v = select(i, ...)
        local t = type(v)
        local serializer

        -- HACK: workaround for color types
        if IsColor(v) then
            serializer = serializers.Color
        else
            serializer = serializers[t]
        end

        x.Assert(serializer, "Type \"%s\" is not supported", t)

        net.WriteUInt(serializer.TypeID, 8)
        serializer.Write(v)
    end
end

function x.NetReadVaargs()
    local readed = {}
    local argc   = net.ReadUInt(8)

    for i = 1, argc do
        local t            = net.ReadUInt(8)
        local deserializer = deserializers[t]

        x.Assert(deserializer, "Tried to read unsupported type %d", t)

        readed[i] = deserializer()
    end

    return readed
end

function x.NetReadVaargsUnpacked()
    return unpack(x.NetReadVaargs())
end
