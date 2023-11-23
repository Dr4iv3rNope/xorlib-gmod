xorlib.Dependency("xorlib/assert", "sh_assert.lua") -- x.Assert

function x.SafeOpenFile(filename, mode, dir, onOpen)
    local f = x.Assert(file.Open(filename, mode, dir), "Failed to open file")

    local success = xpcall(onOpen, x.ErrorNoHaltWithStack, f)

    f:Close()

    return success
end
