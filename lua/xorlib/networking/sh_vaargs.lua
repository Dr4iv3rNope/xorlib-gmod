local unpack = unpack
local select = select

x.NetworkTypesSerializers =
{
	["nil"]	= { t = TYPE_NIL, w = function() end },
	number	= { t = TYPE_NUMBER, w = net.WriteFloat },
	boolean	= { t = TYPE_BOOL, w = net.WriteBool },
	string	= { t = TYPE_STRING, w = net.WriteString },
	table	= { t = TYPE_TABLE, w = net.WriteTable },
	Entity	= { t = TYPE_ENTITY, w = net.WriteEntity },
	Vector	= { t = TYPE_VECTOR, w = net.WriteVector },
	Angle	= { t = TYPE_ANGLE, w = net.WriteAngle },
	Color	= { t = TYPE_COLOR, w = net.WriteColor }
}

x.NetworkTypesSerializers.Player	= x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.Vehicle	= x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.NPC		= x.NetworkTypesSerializers.Entity
x.NetworkTypesSerializers.NextBot	= x.NetworkTypesSerializers.Entity

x.NetworkTypesDeserializers =
{
	[TYPE_NIL]		= function() return nil end,
	[TYPE_NUMBER]	= net.ReadFloat,
	[TYPE_BOOL]		= net.ReadBool,
	[TYPE_STRING]	= net.ReadString,
	[TYPE_VECTOR]	= net.ReadVector,
	[TYPE_ANGLE]	= net.ReadAngle,
	[TYPE_ENTITY]	= net.ReadEntity,
	[TYPE_TABLE]	= net.ReadTable,
	[TYPE_COLOR]	= net.ReadColor
}

local serializers	= x.NetworkTypesSerializers
local deserializers	= x.NetworkTypesDeserializers

function x.NetWriteVaargs(...)
	local argc = select("#", ...)

	net.WriteUInt(argc, 8)

	for i = 1, argc do
		local v = select(i, ...)
		local serializer

		if IsColor(v) then
			serializer = serializers.Color
		else
			serializer = serializers[type(v)]
		end

		net.WriteUInt(serializer.t, 8)
		serializer.w(v)
	end
end

function x.NetReadVaargs()
	local readed = {}
	local argc = net.ReadUInt(8)

	for i = 1, argc do
		local t = net.ReadUInt(8)
		local deserializer = deserializers[t]

		readed[i] = deserializer()
	end

	return readed
end

function x.NetReadVaargsUnpacked()
	return unpack(x.NetReadVaargs())
end
