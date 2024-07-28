xorlib.Dependency("xorlib/assert",     "sh_types.lua")   -- x.Expect*
xorlib.Dependency("xorlib/functional", "sh_getters.lua") -- x.CalleePath

function x.SetupScreenSize(callback, id)
    x.ExpectFunction(callback)
    id = x.ExpectStringOrDefault(id, x.CalleePath(2))

    callback(ScrW(), ScrH())

    hook.Add("OnScreenSizeChanged", id, x.Bind(callback, x._3, x._4))
end
