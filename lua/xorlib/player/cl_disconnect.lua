xorlib.Dependency("xorlib/hook", "sh_hooks.lua") -- HOOK_*

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "xorlib_id_getters", function(data)
	local ply = Player(data.userid)

	hook.Run("PlayerDisonnected", ply)
end, HOOK_MONITOR_LOW)
