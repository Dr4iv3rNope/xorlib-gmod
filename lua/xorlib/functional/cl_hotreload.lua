xorlib.Dependency("xorlib/functional", "sh_hotreload.lua") -- x.EnsureInitPostEntity

function x.EnsureHasLocalPlayer(callback)
    x.EnsureInitPostEntity(function() callback(LocalPlayer()) end)
end
