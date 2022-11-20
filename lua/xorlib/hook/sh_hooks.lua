xorlib.Dependency("xorlib/assert")	-- hook.ImportFromDefaultTable > hook.Add
xorlib.Dependency("xorlib/console")
xorlib.Dependency("xorlib/table")

HOOK_MONITOR_HIGH		= -2
HOOK_HIGH				= -1
HOOK_NORMAL				= 0
HOOK_LOW				= 1
HOOK_MONITOR_LOW		= 2

local xpcall			= xpcall
local type				= type
local rawset			= rawset
local pairs				= pairs
local setmetatable		= setmetatable
local gmod_GetGamemode	= gmod.GetGamemode
local IsValid			= IsValid
local SysTime			= SysTime

x.HookTable				= x.HookTable or {}
x.HookData				= x.HookData or {}
x.HookExecuteList		= x.HookExecuteList or {}

local hookTable			= x.HookTable
local hookData			= x.HookData
local hookExecuteList	= x.HookExecuteList

hook.GetDefaultTable	= hook.GetDefaultTable or hook.GetTable

do
	local HOOK_EVENTS_GUARD = {}
	HOOK_EVENTS_GUARD.__index = HOOK_EVENTS_GUARD

	function HOOK_EVENTS_GUARD.__newindex(hooks, event, v)
		x.Warn("Tried to modify hook table\n%s", debug.traceback())
	end

	setmetatable(hookTable, HOOK_EVENTS_GUARD)
end

local function hookCallbacksGuard(event)
	local HOOK_CALLBACKS_GUARD = {}
	HOOK_CALLBACKS_GUARD.__index = HOOK_CALLBACKS_GUARD

	function HOOK_CALLBACKS_GUARD.__newindex(_, id, callback)
		x.Warn("Hook added avoiding hook.Add\n%s", debug.traceback())

		hook.Add(event, id, callback)
	end

	return setmetatable({}, HOOK_CALLBACKS_GUARD)
end

function hook.ErrorHandler(event, id, callback, errorMessage)
	local debugInfo = debug.getinfo(callback, "S")

	x.ErrorNoHaltWithStack(
		"Error occured while executing hook %s %s (%s:%d)\nWhat: %s",
		event,
		tostring(id),
		debugInfo.source,
		debugInfo.linedefined,
		errorMessage
	)
end

do
	local AUTO_IMPORT_HOOKS = {}
	AUTO_IMPORT_HOOKS.__index = AUTO_IMPORT_HOOKS

	function AUTO_IMPORT_HOOKS.__newindex(hooks, event, v)
		rawset(hooks, event, v ~= nil and hookCallbacksGuard(event) or nil)
	end

	setmetatable(hook.GetDefaultTable(), AUTO_IMPORT_HOOKS)
end

function hook.GetTable()
	return hookTable
end

local nonValidTypes = {
	["boolean"] = true,
	["number"] = true,
	["string"] = true,
	["function"] = true
}

local priorityInserter = {
	[HOOK_MONITOR_HIGH] = function(data, list, callback)
		data.PreCount = data.PreCount + 1

		table.insert(list, 1, callback)
	end,

	[HOOK_HIGH] = function(data, list, callback)
		data.PreCount = data.PreCount + 1

		table.insert(list, data.PreCount, callback)
	end,

	[HOOK_NORMAL] = function(data, list, callback)
		data.Count = data.Count + 1

		table.insert(list, data.PreCount + 1, callback)
	end,

	[HOOK_LOW] = function(data, list, callback)
		table.insert(list, data.PreCount + data.Count + 1, callback)
	end,

	[HOOK_MONITOR_LOW] = function(data, list, callback)
		table.insert(list, callback)
	end
}

function hook.Add(event, id, callback, priority)
	x.ExpectString(event)
	x.Assert(id ~= nil, "id cannot be a nil")
	x.ExpectFunction(callback)
	priority = x.ExpectNumberOrDefault(priority, HOOK_NORMAL)

	hook.Remove(event, id)

	local dict = hookTable[event]
	local data, list

	if dict then
		data = hookData[event]
		list = hookExecuteList[event]
	else
		dict = hookCallbacksGuard(event)
		data = {
			PreCount = 0,
			Count = 0,
			Callbacks = {}
		}
		list = {}

		rawset(hookTable, event, dict)
		hookData[event] = data
		hookExecuteList[event] = list
	end

	rawset(dict, id, callback)

	local listCallback = callback

	-- setting up object hook
	if not nonValidTypes[type(id)] and IsValid(id) then
		local oldCallback = listCallback

		listCallback = function(...)
			if not IsValid(id) then
				hook.Remove(event, id)

				return
			end

			return oldCallback(id, ...)
		end
	end

	-- setting up xpcall callback
	do
		local oldCallback = listCallback

		local function errorHandler(e)
			hook.ErrorHandler(event, id, callback, e)
		end

		listCallback = function(...)
			local success, r1, r2, r3, r4, r5, r6 = xpcall(oldCallback, errorHandler, ...)
			if not success then return end

			return r1, r2, r3, r4, r5, r6
		end
	end

	data.Callbacks[id] = {
		Priority = priority,
		Callback = listCallback
	}

	local newList = x.CopySequence(list)

	local inserter = priorityInserter[priority]
	inserter(data, newList, listCallback)

	hookExecuteList[event] = newList
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

function hook.Remove(event, id)
	x.ExpectString(event)
	x.Assert(id ~= nil, "id cannot be a nil")

	local dict = hookTable[event]
	if not dict then return end
	if not dict[id] then return end

	local data = hookData[event]

	local callbacks = data.Callbacks
	local callback = callbacks[id]

	local priority = callback.Priority

	if priority <= HOOK_HIGH then
		data.PreCount = data.PreCount - 1
	elseif priority == HOOK_NORMAL then
		data.Count = data.Count - 1
	end

	local callbackFn = callback.Callback

	hookExecuteList[event] = x.FilterCopySequence(
		hookExecuteList[event],
		function(v)
			return v ~= callbackFn
		end
	)

	rawset(dict, id, nil)
	callbacks[id] = nil
end

local performanceCaptureEnable			= CreateConVar("xhooks_perfcap_enable", "0")
local performanceCaptureMaxCallTime		= CreateConVar("xhooks_perfcap_max_call_time", "0.002")
local performanceCaptureMaxEventTime	= CreateConVar("xhooks_perfcap_max_event_time", "0.01")
local performanceCaptureFilterEvents	= CreateConVar("xhooks_perfcap_filter_events", "")

local performanceCaptureFilterEventsDict = {}

local function testCallPerformance(event, name, f, ...)
	local startTime = SysTime()

	local r1, r2, r3, r4, r5, r6 = f(...)

	local elapsed = SysTime() - startTime

	if
		not performanceCaptureFilterEventsDict[event] and
		elapsed > performanceCaptureMaxCallTime:GetFloat()
	then
		local info = debug.getinfo(f, "Sn")

		x.Warn(
			"Performance: runtime of hook listener \"%s:%s\" is %.6f sec.\nFunction: %s:%s:%d-%d",
			event,
			name,
			elapsed,
			info.name or "<unknown>",
			info.source,
			info.linedefined,
			info.lastlinedefined
		)
	end

	return r1, r2, r3, r4, r5, r6
end

local function performanceCaptureHookCall(event, gm, ...)
	local list = hookTable[event]

	if list then
		local r1, r2, r3, r4, r5, r6
		local startTime = SysTime()

		for name, callback in pairs(list) do
			r1, r2, r3, r4, r5, r6 = testCallPerformance(event, name, callback, ...)

			if r1 ~= nil then
				goto FORCE_RETURN_VALUE
			end
		end

		::FORCE_RETURN_VALUE::

		local elapsed = SysTime() - startTime

		if elapsed > performanceCaptureMaxEventTime:GetFloat() then
			x.Warn(
				"Performance: runtime of event \"%s\" is %.6f sec.",
				event,
				elapsed
			)
		end

		if r1 ~= nil then
			return r1, r2, r3, r4, r5, r6
		end
	end

	if not gm then return end

	local f = gm[event]
	if not f then return end

	return testCallPerformance(event, "<GAMEMODE>", f, gm, ...)
end

local function normalHookCall(event, gm, ...)
	local list = hookExecuteList[event]

	if list then
		for i = 1, #list do
			local r1, r2, r3, r4, r5, r6 = list[i](...)

			if r1 ~= nil then
				return r1, r2, r3, r4, r5, r6
			end
		end
	end

	if not gm then return end

	local f = gm[event]
	if not f then return end

	return f(gm, ...)
end

hook.Call = normalHookCall

cvars.AddChangeCallback(performanceCaptureEnable:GetName(), function(_, _, value)
	local enable = value ~= "0"

	x.Warn("Hook performance monitor now is %s!", enable and "enabled" or "disabled")

	hook.Call = enable and performanceCaptureHookCall or normalHookCall
end, "")

cvars.AddChangeCallback(performanceCaptureFilterEvents:GetName(), function(_, _, value)
	local filter = string.Explode(",", value)

	for k, hookName in pairs(filter) do
		filter[hookName] = true
		filter[k] = nil
	end

	performanceCaptureFilterEventsDict = filter
end, "")

function hook.Run(event, ...)
	return hook.Call(event, gmod_GetGamemode(), ...)
end

function hook.RemoveAll(event)
	rawset(hookTable, event, {})

	hookData[event] = {
		PreCount = 0,
		Count = 0,
		Callbacks = {}
	}

	hookExecuteList[event] = {}
end

function hook.Count(event)
	local callbacks = hookExecuteList[event]

	return callbacks and #callbacks or 0
end

function hook.ImportFromDefaultTable()
	local hooks = hook.GetDefaultTable()

	for event, data in pairs(hooks) do
		for id, callback in pairs(data) do
			x.Warn("Importing hook from gmod hook system %s %s", event, tostring(id))

			hook.Add(event, id, callback)
		end

		rawset(hooks, event, nil)
	end
end

hook.ImportFromDefaultTable()

--
-- disallowing load ulib hooks
--
x._OldInclude = x._OldInclude or include

function include(path)
	if path:EndsWith("ulib/shared/hook.lua") then
		x.Warn("Disallow loading ULib hook system")

		return
	end

	return x._OldInclude(path)
end
