local pairs = pairs

function x.MapSequence(tbl, callback)
    for i = 1, #tbl do
        local newValue = callback(tbl[i])

        if newValue ~= nil then
            tbl[i] = newValue
        end
    end

    return tbl
end

function x.MapCopySequence(tbl, callback)
    local newTable = {}

    for i = 1, #tbl do
        local v = tbl[i]
        local newValue = callback(v)

        if newValue ~= nil then
            newTable[i] = newValue
        else
            newTable[i] = v
        end
    end

    return newTable
end

function x.MapPairs(tbl, callback)
    for k, v in pairs(tbl) do
        local newValue, newKey = callback(v, k)

        if newValue ~= nil then
            if newKey ~= nil then
                tbl[k] = nil
                tbl[newKey] = newValue
            else
                tbl[k] = newValue
            end
        end
    end

    return tbl
end

function x.MapCopyPairs(tbl, callback)
    local newTable = {}

    for k, v in pairs(tbl) do
        local newValue, newKey = callback(v, k)

        if newValue ~= nil then
            if newKey ~= nil then
                newTable[newKey] = newValue
            else
                newTable[k] = newValue
            end
        else
            newTable[k] = v
        end
    end

    return newTable
end

function x.MapIntoSequence(tbl, callback)
    local i = 1

    for k, v in pairs(tbl) do
        local newValue = callback(v, k)

        tbl[i] = newValue

        i = i + 1
    end

    return tbl
end

function x.MapCopyIntoSequence(tbl, callback)
    local newTable = {}
    local i = 1

    for k, v in pairs(tbl) do
        local newValue = callback(v, k)

        newTable[i] = newValue

        i = i + 1
    end

    return newTable
end
