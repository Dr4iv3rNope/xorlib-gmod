xorlib.Dependency("xorlib/hook", "sh_utils.lua") -- hook.Once

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
	if not x._InitPostEntity then
		local name = tostring(table.Count(hook.GetTable().InitPostEntity or {}) + 1)

		hook.Once("InitPostEntity", name, function()
			callback()
		end)
	else
		callback()
	end
end

if not x._InitPostEntity then
	hook.Once("InitPostEntity", "xorlib initpostentity", function()
		x._InitPostEntity = true

		x.Print("InitPostEntity!")
	end, HOOK_MONITOR_HIGH)
end
