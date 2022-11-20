xorlib.Dependency("xorlib/hook", "sh_hooks.lua")	-- HOOK_*
xorlib.Dependency("xorlib/table", "sh_remove.lua")	-- x.EmptySequence

x.PlayerGettersCache = x.PlayerGettersCache or {}

function x.RebuildPlayerGetters(funcName)
	local cache		= x.Assert(x.PlayerGettersCache[funcName], "Player getters \"%s\" is not registered!", funcName)
	local filter	= cache.Filter
	local players	= player.GetAll()

	x.EmptySequence(cache.Players)

	for i = 1, #players do
		local ply = players[i]

		if filter(ply) then
			table.insert(cache.Players, ply)
		end
	end
end

function x.RegisterPlayerGetters(funcName, filter)
	local cachedPlayers = x.PlayerGettersCache[funcName]

	if cachedPlayers then
		cachedPlayers = cachedPlayers.Players

		x.RebuildPlayerGetters(funcName)
	else
		local cache = {
			FunctionName	= funcName,
			Filter			= filter,
			Players			= {}
		}

		x.PlayerGettersCache[funcName] = cache
		cachedPlayers = cache.Players
	end

	hook.Add("PlayerInitialSpawn", "xorlib_player_getter_" .. funcName, function(ply)
		if not filter(ply) then return end

		table.insert(cachedPlayers, ply)
	end, HOOK_MONITOR_HIGH)

	hook.Add("PlayerDisconnected", "xorlib_player_getter_" .. funcName, function(ply)
		x.RemoveSequenceValue(cachedPlayers, ply)
	end)

	local fullFuncName = "Get" .. funcName .. "Players"

	x[fullFuncName] = function()
		return cachedPlayers
	end
end

x.EnsureInitialized(function()
	x.RegisterPlayerGetters("SuperAdmin", x.Meta("Player", "IsSuperAdmin"))
	x.RegisterPlayerGetters("Admin", x.Meta("Player", "IsAdmin"))
end)
