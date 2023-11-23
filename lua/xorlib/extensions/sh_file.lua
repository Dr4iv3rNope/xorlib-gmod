xorlib.Dependency("xorlib/assert", "sh_assert.lua") -- x.Assert

local FILE = FindMetaTable("File")

function FILE:WriteBoolean(boolean)
    x.ExpectBoolean(boolean)

    self:WriteByte(boolean and 1 or 0)
end

function FILE:WriteVector(vector)
    x.ExpectVector(vector)

    self:WriteFloat(vector.x)
    self:WriteFloat(vector.y)
    self:WriteFloat(vector.z)
end

function FILE:WriteAngle(angle)
    x.ExpectAngle(angle)

    self:WriteFloat(angle.p)
    self:WriteFloat(angle.y)
    self:WriteFloat(angle.r)
end

function FILE:WriteColor(color)
    x.ExpectTable(color)

    self:WriteByte(color.r)
    self:WriteByte(color.g)
    self:WriteByte(color.b)
    self:WriteByte(color.a)
end

local function writeStringInternal(f, codepoint, ...)
    if codepoint == nil then
        return
    end

    f:WriteByte(codepoint)

    writeStringInternal(f, ...)
end

function FILE:WriteString(str)
    writeStringInternal(self, utf8.codepoint(str, 1, -1))
    self:WriteByte(0)
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

local function readStringInternal(f, ...)
    local codepoint = f:ReadByte()

    if codepoint ~= 0 and not f:EndOfFile() then
        return readStringInternal(f, ..., codepoint)
    end

    return utf8.char(...)
end

function FILE:ReadString()
    return readStringInternal(self)
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
    local f = x.Assert(file.Open(filename, mode, dir),
                       "failed to open file")

    local success = xpcall(onOpen, x.ErrorNoHaltWithStack, f)

    f:Close()

    return success
end
