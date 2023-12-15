xorlib.Dependency("xorlib/table", "sh_filter.lua") -- x.FilterPairs

x.TimeoutTable           = x.TimeoutTable or {}

local CurTime            = CurTime
local globalTimeoutTable = x.TimeoutTable

function x.TimeoutSet(id, seconds)
    globalTimeoutTable[id] = CurTime() + seconds
end

function x.TimeoutSetUntil(id, time)
    globalTimeoutTable[id] = time
end

function x.TimeoutAction(id, seconds)
    local t = CurTime()

    local nextAction = globalTimeoutTable[id] or 0

    if nextAction > t then
        return false
    end

    globalTimeoutTable[id] = t + seconds
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
