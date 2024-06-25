-- If you want to modify xorlib's behavior, create file "lua/xorlib/!.xorlib_setup.lua" and make changes there.

function xorlib.PreInclude(subpath, filename)
    -- Preventing xorlib hooks from loading
    if subpath == "xorlib/hook" and filename == "sh_hooks.lua" then
        return false
    end

    return true
end
