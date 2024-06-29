xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Print
xorlib.Dependency("xorlib/hook", "sh_utils.lua") -- hook.Once

function x.EnsureInitialized(callback)
    if not GAMEMODE then
        local callbacks = hook.GetTable().Initialize or {}
        local name      = tostring(table.Count(callbacks) + 1)

        hook.Once("Initialize", name, callback)
    else
        callback()
    end
end

function x.EnsureInitPostEntity(callback)
    if not x._InitPostEntity then
        local callbacks = hook.GetTable().InitPostEntity or {}
        local name      = tostring(table.Count(callbacks) + 1)

        hook.Once("InitPostEntity", name, callback)
    else
        callback()
    end
end

if not x._InitPostEntity then
    hook.Once("InitPostEntity", "xorlib initpostentity", function()
        x._InitPostEntity = true
    end, HOOK_MONITOR_HIGH)
end
