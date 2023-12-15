xorlib.Dependency("xorlib/table", "sh_filter.lua") -- x.FilterPairs

x.TimeoutTable           = x.TimeoutTable or {}

local CurTime            = CurTime
local globalTimeoutTable = x.TimeoutTable

function x.TimeoutSet(id, timeout)
    globalTimeoutTable[id] = CurTime() + timeout
end

function x.TimeoutSetUntil(id, time)
    globalTimeoutTable[id] = time
end

function x.TimeoutAction(id, timeout)
    local t = CurTime()

    local nextAction = globalTimeoutTable[id] or 0

    if nextAction > t then
        return false
    end

    globalTimeoutTable[id] = t + timeout
    return true
end

function x.TimeoutGetUntil(id)
    return globalTimeoutTable[id] or 0
end

local timeoutGetUntil = x.TimeoutGetUntil

function x.TimeoutGetLeft(id)
    return timeoutGetUntil(id) - CurTime()
end

function x.TimeoutIsExpired(id)
    return CurTime() > timeoutGetUntil(id)
end

function x.TimeoutClear(id)
    globalTimeoutTable[id] = nil
end

timer.Create("xorlib_timeout_cleanup", 60, 0, function()
    local t = CurTime()

    x.FilterPairs(globalTimeoutTable, function(nextCheck)
        return t > nextCheck
    end)
end)

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetTimeoutTable()
    local timeoutTable = self._xorlibTimeoutTable

    if not timeoutTable then
        timeoutTable = {}

        self._xorlibTimeoutTable = timeoutTable
    end

    return timeoutTable
end

function ENTITY:TimeoutSet(id, timeout)
    local timeoutTable = self:GetTimeoutTable()

    timeoutTable[id] = CurTime() + timeout
end

function ENTITY:TimeoutSetUntil(id, time)
    local timeoutTable = self:GetTimeoutTable()

    timeoutTable[id] = time
end

function ENTITY:TimeoutAction(id, timeout)
    local timeoutTable = self:GetTimeoutTable()
    local t = CurTime()

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

function ENTITY:TimeoutGetLeft(id)
    return self:TimeoutGetUntil(id) - CurTime()
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
