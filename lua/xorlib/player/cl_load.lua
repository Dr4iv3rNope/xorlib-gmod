net.Receive("xorlib_player_initial_spawn", function()
	local ply = net.ReadEntity()

	hook.Call("PlayerInitialSpawn", nil, ply)
end)

net.Receive("xorlib_player_ready", function()
	local ply = net.ReadEntity()

	hook.Call("PlayerReady", nil, ply)
end)
