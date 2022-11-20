util.AddNetworkString("xorlib_player_initial_spawn")
util.AddNetworkString("xorlib_player_ready")

local function playerReady(ply)
	hook.Call("PlayerReady", nil, ply)

	net.Start("xorlib_player_ready")
	net.WriteEntity(ply)
	net.SendOmit(ply)
end

hook.Add("PlayerInitialSpawn", "xorlib_network_player", function(ply)
	if ply:IsBot() then
		playerReady(ply)

		return
	end

	net.Start("xorlib_player_initial_spawn")
	net.WriteEntity(ply)
	net.SendOmit(ply)

	local hookName = "xorlib_network_player_init_" .. ply:UserID()

	hook.Add("SetupMove", hookName, function(smply, _, cmd)
		if smply ~= ply then return end
		if cmd:IsForced() then return end

		hook.Remove("SetupMove", hookName)

		playerReady(ply)
	end)
end)

hook.Add("PlayerDisconnected", "xorlib_network_player", function(ply)
	if ply:IsBot() then return end

	hook.Remove("SetupMove", "xorlib_network_player_init_" .. ply:UserID())
end)
