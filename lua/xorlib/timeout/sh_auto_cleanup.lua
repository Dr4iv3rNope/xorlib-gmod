xorlib.Dependency("xorlib/table",   "sh_filter.lua")
xorlib.Dependency("xorlib/timeout", "sh_timeout.lua")

local CurTime            = CurTime
local globalTimeoutTable = x.TimeoutTable

timer.Create("xorlib_timeout_cleanup", 60, 0, function()
    local t = CurTime()

    x.FilterPairs(globalTimeoutTable, function(nextCheck)
        return t > nextCheck
    end)
end)
