gameevent.Listen("player_activate")

hook.Add("player_activate", "xorlib_network_player", function(data)
	timer.Simple(0, function()
		local ply = Player(data.userid)

		if not IsValid(ply) then return end

		hook.Run("PlayerInitialSpawn", ply)
	end)
end, HOOK_MONITOR_HIGH)

net.Receive("xorlib_player_ready", function()
	local ply = net.ReadEntity()

	hook.Call("PlayerReady", nil, ply)
end)
