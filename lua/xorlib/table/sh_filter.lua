local table_remove = table.remove
local pairs        = pairs

function x.FilterSequence(tbl, callback)
    local filtered = 0

    for i = 1, #tbl do
        local realIndex = i - filtered

        if not callback(tbl[realIndex]) then
            table_remove(tbl, realIndex)

            filtered = filtered + 1
        end
    end

    return tbl
end

function x.FilterCopySequence(tbl, callback)
    local newTable = {}

    for i = 1, #tbl do
        local v = tbl[i]

        if callback(v) then
            newTable[#newTable + 1] = v
        end
    end

    return newTable
end

function x.FilterPairs(tbl, callback)
    for k, v in pairs(tbl) do
        if not callback(k, v) then
            tbl[k] = nil
        end
    end

    return tbl
end

function x.FilterCopyPairs(tbl, callback)
    local newTable = {}

    for k, v in pairs(tbl) do
        if callback(k, v) then
            newTable[k] = v
        end
    end

    return newTable
end

function x.FilterKeys(tbl, callback)
    for k, _ in pairs(tbl) do
        if not callback(k) then
            tbl[k] = nil
        end
    end

    return tbl
end

function x.FilterCopyKeys(tbl, callback)
    local newTable = {}

    for k, v in pairs(tbl) do
        if callback(k) then
            newTable[k] = v
        end
    end

    return newTable
end

function x.FilterValues(tbl, callback)
    for k, v in pairs(tbl) do
        if not callback(v) then
            tbl[k] = nil
        end
    end

    return tbl
end

function x.FilterCopyValues(tbl, callback)
    local newTable = {}

    for k, v in pairs(tbl) do
        if callback(v) then
            newTable[k] = v
        end
    end

    return newTable
end
