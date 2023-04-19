xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Error, x.Warn, etc.
xorlib.Dependency("xorlib/extensions", "sh_file.lua") -- file.OpenProtected

local FILE = FindMetaTable("File")

local BIN_TABLE_TYPE_TABLE_BEGIN = 0
local BIN_TABLE_TYPE_TABLE_END = 1
local BIN_TABLE_TYPE_NIL = 2
local BIN_TABLE_TYPE_BOOLEAN = 3
local BIN_TABLE_TYPE_NUMBER = 4
local BIN_TABLE_TYPE_DOUBLE = 5
local BIN_TABLE_TYPE_STRING = 6
local BIN_TABLE_TYPE_COLOR = 7
local BIN_TABLE_TYPE_VECTOR = 8
local BIN_TABLE_TYPE_ANGLE = 9

--
-- binary table reader
--

local binaryTableReader = {}

binaryTableReader[BIN_TABLE_TYPE_TABLE_BEGIN] = function(f)
	return f:ReadBinaryTable(true)
end

binaryTableReader[BIN_TABLE_TYPE_TABLE_END] = function(f)
	x.Error("Got BIN_TABLE_TYPE_TABLE_END while trying to read value")
end

binaryTableReader[BIN_TABLE_TYPE_NIL] = function(f)
	return nil
end

binaryTableReader[BIN_TABLE_TYPE_BOOLEAN] = function(f)
	return f:ReadBoolean()
end

binaryTableReader[BIN_TABLE_TYPE_NUMBER] = function(f)
	return f:ReadLong()
end

binaryTableReader[BIN_TABLE_TYPE_DOUBLE] = function(f)
	return f:ReadDouble()
end

binaryTableReader[BIN_TABLE_TYPE_STRING] = function(f)
	return f:ReadString()
end

binaryTableReader[BIN_TABLE_TYPE_COLOR] = function(f)
	return f:ReadColor()
end

binaryTableReader[BIN_TABLE_TYPE_VECTOR] = function(f)
	return f:ReadVector()
end

binaryTableReader[BIN_TABLE_TYPE_ANGLE] = function(f)
	return f:ReadAngle()
end

local function peekBinaryTableType(f)
	local prev_pos = f:Tell()
	local t = f:ReadByte()

	f:Seek(prev_pos)
	return t
end

local function binaryTableReadValue(f)
	local t = f:ReadByte()
	local reader = binaryTableReader[t]

	if reader then
		return reader(f), true
	else
		x.Warn("Unknown type %s", tostring(t))

		return nil, false
	end
end

function FILE:ReadBinaryTable(ignoreBegin)
	local tbl = {}

	if not ignoreBegin then
		local t = self:ReadByte()

		if t ~= BIN_TABLE_TYPE_TABLE_BEGIN then
			x.Warn("BIN_TABLE_TYPE_TABLE_BEGIN expected, got %s", tostring(t))

			return nil
		end
	end

	while peekBinaryTableType(self) ~= BIN_TABLE_TYPE_TABLE_END do
		if self:EndOfFile() then
			x.Warn("Unexpected EOF")

			return nil
		end

		local k, v, success

		k, success = binaryTableReadValue(self)
		if not success then return nil end

		v, success = binaryTableReadValue(self)
		if not success then return nil end

		tbl[k] = v
	end

	self:Skip(1)
	return tbl
end

function file.ReadBinaryTable(filename)
	local tbl

	file.OpenProtected(filename, "rb", "DATA", function(f)
		tbl = f:ReadBinaryTable()
	end)

	return tbl
end

--
-- binary table writer
--

local binaryTableWriter = {}

binaryTableWriter["number"] = function(f, num)
	local isFloat = math.ceil(num) ~= num

	if isFloat then
		f:WriteByte(BIN_TABLE_TYPE_DOUBLE)
		f:WriteDouble(num)
	else
		f:WriteByte(BIN_TABLE_TYPE_NUMBER)
		f:WriteLong(num)
	end
end

binaryTableWriter["nil"] = function(f)
	f:WriteByte(BIN_TABLE_TYPE_NIL)
end

binaryTableWriter["boolean"] = function(f, bool)
	f:WriteByte(BIN_TABLE_TYPE_BOOLEAN)
	f:WriteBoolean(bool)
end

binaryTableWriter["string"] = function(f, str)
	f:WriteByte(BIN_TABLE_TYPE_STRING)
	f:WriteString(str)
end

binaryTableWriter["Vector"] = function(f, vec)
	f:WriteByte(BIN_TABLE_TYPE_VECTOR)
	f:WriteVector(vec)
end

binaryTableWriter["Angle"] = function(f, ang)
	f:WriteByte(BIN_TABLE_TYPE_ANGLE)
	f:WriteAngle(ang)
end

local function binaryTableWriteValue(f, v, written_tables)
	local t = type(v)
	local writer = binaryTableWriter[t]

	if writer then
		writer(f, v)
	elseif t == "table" then
		f:WriteBinaryTable(v, written_tables)
	elseif IsColor(v) then
		f:WriteByte(BIN_TABLE_TYPE_COLOR)
		f:WriteColor(v)
	else
		x.Warn("Type \"%s\" is not supported! Writing nil instead...", t)

		binaryTableWriter["nil"](f)
	end
end

function FILE:WriteBinaryTable(tbl, writtenTables)
	writtenTables = writtenTables or {}

	if writtenTables[tbl] then
		x.Print("Recursive table detected: %s. Writing nil instead...", tostring(tbl))

		binaryTableWriter["nil"](self)
		return
	end

	writtenTables[tbl] = true

	self:WriteByte(BIN_TABLE_TYPE_TABLE_BEGIN)

	for k, v in pairs(tbl) do
		binaryTableWriteValue(self, k, writtenTables)
		binaryTableWriteValue(self, v, writtenTables)
	end

	self:WriteByte(BIN_TABLE_TYPE_TABLE_END)
end

function file.WriteBinaryTable(filename, tbl)
	file.OpenProtected(filename, "wb", "DATA", function(f)
		f:WriteBinaryTable(tbl)
	end)
end

--
-- debug
--

local BIN_TRANSLATE = {
	[BIN_TABLE_TYPE_TABLE_BEGIN] = "BIN_TABLE_TYPE_TABLE_BEGIN",
	[BIN_TABLE_TYPE_TABLE_END] = "BIN_TABLE_TYPE_TABLE_END",
	[BIN_TABLE_TYPE_NIL] = "BIN_TABLE_TYPE_NIL",
	[BIN_TABLE_TYPE_BOOLEAN] = "BIN_TABLE_TYPE_BOOLEAN",
	[BIN_TABLE_TYPE_NUMBER] = "BIN_TABLE_TYPE_NUMBER",
	[BIN_TABLE_TYPE_DOUBLE] = "BIN_TABLE_TYPE_DOUBLE",
	[BIN_TABLE_TYPE_STRING] = "BIN_TABLE_TYPE_STRING",
	[BIN_TABLE_TYPE_COLOR] = "BIN_TABLE_TYPE_COLOR",
	[BIN_TABLE_TYPE_VECTOR] = "BIN_TABLE_TYPE_VECTOR",
	[BIN_TABLE_TYPE_ANGLE] = "BIN_TABLE_TYPE_ANGLE",
}

function file.TokenizeBinaryTable(filename)
	file.OpenProtected(filename, "rb", "DATA", function(f)
		while not f:EndOfFile() do
			local pos = f:Tell()
			local t = f:ReadByte()
			local v = binaryTableReader[t]

			if v and t ~= BIN_TABLE_TYPE_TABLE_BEGIN and t ~= BIN_TABLE_TYPE_TABLE_END then
				v = tostring(v(f))
			else
				v = "<no value>"
			end

			print(pos, BIN_TRANSLATE[t] or "<unknown>", v)
		end
	end)
end