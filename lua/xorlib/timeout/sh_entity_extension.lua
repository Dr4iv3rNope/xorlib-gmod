local CurTime = CurTime

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetTimeoutTable()
    local timeoutTable = self._xorlibTimeoutTable

    if not timeoutTable then
        timeoutTable = {}

        self._xorlibTimeoutTable = timeoutTable
    end

    return timeoutTable
end

function ENTITY:TimeoutSet(id, seconds)
    local timeoutTable = self:GetTimeoutTable()

    timeoutTable[id] = CurTime() + seconds
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
