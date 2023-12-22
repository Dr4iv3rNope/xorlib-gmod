xorlib.Dependency("xorlib/console",    "sh_print.lua")
xorlib.Dependency("xorlib/functional", "sh_getters.lua")

function xorlib.CheckDevBranchFunction(entry, functionPath)
    local functionToCheck = x.Index(entry, functionPath)

    if functionToCheck ~= nil then
        x.ErrorNoHalt("Dev branch function \"%s\" is available! " ..
                      "Remove temporary implementaion!",
                      functionPath)

        return true
    end

    return false
end
