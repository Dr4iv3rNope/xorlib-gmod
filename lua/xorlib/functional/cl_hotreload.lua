function x.EnsureHasLocalPlayer(callback)
	x.EnsureInitPostEntity(function() callback(LocalPlayer()) end)
end
