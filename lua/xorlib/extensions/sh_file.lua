local FILE = FindMetaTable("File")

function FILE:WriteBoolean(bool)
	x.ExpectBoolean(bool)

	self:WriteByte(bool and 1 or 0)
end

function FILE:WriteVector(vec)
	x.ExpectVector(vec)

	self:WriteFloat(vec.x)
	self:WriteFloat(vec.y)
	self:WriteFloat(vec.z)
end

function FILE:WriteAngle(ang)
	x.ExpectAngle(ang)

	self:WriteFloat(ang.p)
	self:WriteFloat(ang.y)
	self:WriteFloat(ang.r)
end

function FILE:WriteColor(color)
	x.ExpectTable(color)

	self:WriteByte(color.r)
	self:WriteByte(color.g)
	self:WriteByte(color.b)
	self:WriteByte(color.a)
end

function FILE:WriteString(str)
	x.ExpectString(str)

	if #str ~= 0 then
		for i, codepoint in ipairs({ utf8.codepoint(str, 1, -1) }) do
			self:WriteUShort(codepoint)
		end
	end

	self:WriteUShort(0)
end

function FILE:ReadBoolean()
	return self:ReadByte() ~= 0
end

function FILE:ReadVector()
	local x = self:ReadFloat()
	local y = self:ReadFloat()
	local z = self:ReadFloat()

	return Vector(x, y, z)
end

function FILE:ReadAngle()
	local p = self:ReadFloat()
	local y = self:ReadFloat()
	local r = self:ReadFloat()

	return Angle(p, y, r)
end

function FILE:ReadColor()
	local r = self:ReadByte()
	local g = self:ReadByte()
	local b = self:ReadByte()
	local a = self:ReadByte()

	return Color(r, g, b, a)
end

function FILE:ReadString()
	local str = ""

	while not self:EndOfFile() do
		local codepoint = self:ReadUShort()
		if codepoint == 0 then break end

		str = str .. utf8.char(codepoint)
	end

	return str
end

function FILE:ReadUByte()
	return 128 + self:ReadByte()
end

function FILE:ReadLongLong()
	local low = self:ReadULong()
	local high = self:ReadLong()

	return high * 4294967296 + low
end

function FILE:ReadULongLong()
	local low = self:ReadULong()
	local high = self:ReadULong()

	return high * 4294967296 + low
end

function FILE:ReadStringASCII()
	local str = ""

	while not self:EndOfFile() do
		local char = self:ReadByte()
		if char == 0 then break end

		str = str .. string.char(char)
	end

	return str
end

function file.OpenProtected(filename, mode, dir, onOpen)
	local f = file.Open(filename, mode, dir)
	assert(f, "failed to open file")

	local success = xpcall(onOpen, x.ErrorNoHaltWithStack, f)

	f:Close()

	return success
end
