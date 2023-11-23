local function readStringBytes(f, ...)
    local codepoint = f:ReadByte()

    if codepoint ~= 0 and not f:EndOfFile() then
        return readStringBytes(f, ..., codepoint)
    end

    return ...
end

function x.FileReadBoolean(fileObject)
    return fileObject:ReadByte() ~= 0
end

function x.FileReadVector(fileObject)
    local x = fileObject:ReadFloat()
    local y = fileObject:ReadFloat()
    local z = fileObject:ReadFloat()

    return Vector(x, y, z)
end

function x.FileReadAngle(fileObject)
    local p = fileObject:ReadFloat()
    local y = fileObject:ReadFloat()
    local r = fileObject:ReadFloat()

    return Angle(p, y, r)
end

function x.FileReadColor(fileObject, readAlpha)
    local r = fileObject:ReadByte()
    local g = fileObject:ReadByte()
    local b = fileObject:ReadByte()
    local a = readAlpha ~= false
              and fileObject:ReadByte()
              or  255

    return Color(r, g, b, a)
end

function x.FileReadStringASCII(fileObject)
    return string.byte(readStringBytes(fileObject))
end

function x.FileReadString(fileObject)
    return utf8.char(readStringBytes(fileObject))
end

function x.FileReadUByte(fileObject)
    return 128 + fileObject:ReadByte()
end

function x.FileReadLongLong(fileObject)
    local low = fileObject:ReadULong()
    local high = fileObject:ReadLong()

    return high * 4294967296 + low
end

function x.FileReadULongLong(fileObject)
    local low = fileObject:ReadULong()
    local high = fileObject:ReadULong()

    return high * 4294967296 + low
end
