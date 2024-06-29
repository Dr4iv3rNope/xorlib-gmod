xorlib.Dependency("xorlib/hook", "sh_hooks.lua") -- HOOK_*

x.UserIDPlayerInstanceCache = x.UserIDPlayerInstanceCache or {}

hook.Add("CL_PlayerInitialSpawn", "xorlib_cl_disconnect", function(ply)
    x.UserIDPlayerInstanceCache[ply:UserID()] = ply
end, HOOK_MONITOR_HIGH)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "xorlib_cl_disconnect", function(data)
    local ply = x.UserIDPlayerInstanceCache[data.userid]

    x.UserIDPlayerInstanceCache[data.userid] = nil

    hook.Run("CL_PlayerDisconnected", ply)
end, HOOK_MONITOR_LOW)
