x.TimeoutTable		= x.TimeoutTable or {}
local timeoutTable	= x.TimeoutTable

local CurTime = CurTime

function x.TimeoutAction(id, timeout)
	local t = CurTime()

	local nextAction = timeoutTable[id] or 0

	if nextAction > t then
		return false
	end

	timeoutTable[id] = t + timeout
	return true
end

function x.TimeoutGetUntil(id)
	return timeoutTable[id] or 0
end

local timeoutGetUntil = x.TimeoutGetUntil

function x.TimeoutIsExpired(id)
	return CurTime() > timeoutGetUntil(id)
end

function x.TimeoutClear(id)
	timeoutTable[id] = nil
end

timer.Create("xorlib_timeout_cleanup", 60, 0, function()
	local t = CurTime()

	x.FilterPairs(timeoutTable, function(nextCheck)
		return t > nextCheck
	end)
end)

local ENTITY = FindMetaTable("Entity")

function ENTITY:TimeoutAction(id, timeout)
	local timeoutTable = self._xorlibTimeoutTable
	local t = CurTime()

	if not timeoutTable then
		timeoutTable = {}

		self._xorlibTimeoutTable = timeoutTable
	end

	local nextAction = timeoutTable[id] or 0

	if nextAction > t then
		return false
	end

	timeoutTable[id] = t + timeout
	return true
end

function ENTITY:TimeoutGetUntil(id)
	local timeoutTable = self._xorlibTimeoutTable
	if not timeoutTable then return 0 end

	return timeoutTable[id] or 0
end

function ENTITY:TimeoutIsExpired(id)
	return CurTime() > self:TimeoutGetUntil(id)
end

function ENTITY:TimeoutClear(id)
	local timeoutTable = self._xorlibTimeoutTable
	if not timeoutTable then return end

	timeoutTable[id] = nil
end

function ENTITY:TimeoutClearAll()
	self._xorlibTimeoutTable = nil
end
