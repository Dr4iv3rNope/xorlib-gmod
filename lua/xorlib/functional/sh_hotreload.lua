xorlib.Dependency("xorlib/hook", "sh_hooks.lua") -- hook.Once

function x.EnsureInitialized(callback)
	if not GAMEMODE then
		local callbacks	= hook.GetTable().Initialize or {}
		local name		= tostring(table.Count(callbacks) + 1)

		hook.Once("Initialize", name, function()
			callback()
		end)
	else
		callback()
	end
end

function x.EnsureInitPostEntity(callback)
	local callbacks = hook.GetTable().InitPostEntity or {}
	local hasLibraryPlaceholder = callbacks["xorlib initpostentity"] ~= nil

	if hasLibraryPlaceholder then
		local name = tostring(table.Count(callbacks) + 1)

		hook.Once("InitPostEntity", name, function()
			callback()
		end)
	else
		callback()
	end
end

hook.Once("InitPostEntity", "xorlib initpostentity", function() x.Print("InitPostEntity!") end, HOOK_MONITOR_HIGH)
