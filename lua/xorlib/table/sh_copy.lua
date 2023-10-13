local pairs = pairs

function x.CopySequence(tbl)
    local newTable = {}

    for i = 1, #tbl do
        newTable[i] = tbl[i]
    end

    return newTable
end

function x.CopyPairs(tbl)
    local newTable = {}

    for k, v in pairs(tbl) do
        newTable[k] = v
    end

    return newTable
end
