local XORLIB_HOOKS = xorlib.Dependency("xorlib/hook", "sh_hooks.lua")
xorlib.Dependency("xorlib/assert", "sh_types.lua") -- x.Expect*

local hookRemoveAll
local hookCount

if XORLIB_HOOKS then
	local hookTable			= x.HookTable
	local hookData			= x.HookData
	local hookExecuteList	= x.HookExecuteList

	function hookRemoveAll(event)
		rawset(hookTable, event, {})

		hookData[event] = {
			PreCount = 0,
			Count = 0,
			Callbacks = {}
		}

		hookExecuteList[event] = {}
	end

	function hookCount(event)
		local callbacks = hookExecuteList[event]

		return callbacks and #callbacks or 0
	end
else
	function hookRemoveAll(event)
		for id, _ in pairs(hook.GetTable()[event] or {}) do
			hook.Remove(event, id)
		end
	end

	function hookCount(event)
		return table.Count(hook.GetTable()[event] or {})
	end
end

function hook.Once(event, id, callback, priority)
	x.ExpectFunction(callback)

	local oldCallback = callback

	callback = function(...)
		hook.Remove(event, id)

		oldCallback(...)
	end

	hook.Add(event, id, callback, priority)
end

function hook.RemoveAll(event)
	hookRemoveAll(event)
end

function hook.Count(event)
	return hookCount(event)
end
