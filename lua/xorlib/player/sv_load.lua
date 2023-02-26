util.AddNetworkString("xorlib_player_ready")

hook.Add("PlayerInitialSpawn", "xorlib_network_player", function(ply)
	local hookName = "xorlib_network_player_init_" .. ply:UserID()

	hook.Add("SetupMove", hookName, function(smply, _, cmd)
		if smply ~= ply then return end
		if cmd:IsForced() then return end

		hook.Remove("SetupMove", hookName)

		hook.Run("PlayerReady", ply)

		net.Start("xorlib_player_ready")
		net.WriteEntity(ply)
		net.SendOmit(ply)
	end)
end)

hook.Add("PlayerDisconnected", "xorlib_network_player", function(ply)
	hook.Remove("SetupMove", "xorlib_network_player_init_" .. ply:UserID())
end)
