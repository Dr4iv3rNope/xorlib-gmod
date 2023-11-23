function x.FileWriteBoolean(fileObject, boolean)
    fileObject:WriteByte(boolean and 1 or 0)
end

function x.FileWriteVector(fileObject, vector)
    fileObject:WriteFloat(vector.x)
    fileObject:WriteFloat(vector.y)
    fileObject:WriteFloat(vector.z)
end

function x.FileWriteAngle(fileObject, angle)
    fileObject:WriteFloat(angle.p)
    fileObject:WriteFloat(angle.y)
    fileObject:WriteFloat(angle.r)
end

function x.FileWriteColor(fileObject, color, writeAlpha)
    fileObject:WriteByte(color.r)
    fileObject:WriteByte(color.g)
    fileObject:WriteByte(color.b)

    if writeAlpha ~= false then
        fileObject:WriteByte(color.a)
    end
end

function x.FileWriteString(fileObject, str)
    local function writeStringInternal(f, codepoint, ...)
        if codepoint == nil then
            return
        end

        f:WriteByte(codepoint)

        writeStringInternal(f, ...)
    end

    writeStringInternal(fileObject, utf8.codepoint(str, 1, -1))
    fileObject:WriteByte(0)
end
