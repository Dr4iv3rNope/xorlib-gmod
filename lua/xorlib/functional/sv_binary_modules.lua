xorlib.Dependency("xorlib/assert",  "sh_types.lua") -- x.Expect*
xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.ErrorNoHalt

function x.RequireModule(name)
    x.ExpectString(name)

    if not util.IsBinaryModuleInstalled(name) then
        return false, string.format("Binary module \"%s\" not installed", name)
    end

    local success, err = pcall(require, name)

    if not success then
        return false, string.format("Failed to require binary module \"%s\": %s", name, err)
    end

    return true
end
