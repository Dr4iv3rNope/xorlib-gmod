local table_insert = table.insert
local table_remove = table.remove
local next         = next

xorlib.MAP = xorlib.MAP or {}

local MAP = xorlib.MAP
MAP.__index = MAP

function MAP:Length()
    return #self.Values
end

function MAP:Has(key)
    return self.Indicies[key] ~= nil
end

function MAP:Index(key)
    return self.Indicies[key]
end

function MAP:Get(key)
    return self.Values[self.Indicies[key]]
end

function MAP:Set(key, value)
    local indicies = self.Indicies
    local values   = self.Values

    local index = indicies[key]

    if index ~= nil then
        -- override value
        values[index] = value
    else
        -- insert new value
        indicies[key] = table_insert(values, value)
    end
end

function MAP:Delete(key)
    local indicies = self.Indicies
    local values   = self.Values

    local index = indicies[key]
    if index == nil then return end

    local value = table_remove(values, index)

    indicies[key] = nil

    return value
end

function MAP:Iterate()
    local indicies = self.Indicies
    local values   = self.Values

    local prevKey = nil

    return function()
        local key, index = next(indicies, prevKey)

        if key == nil then
            return nil -- end of iteration
        end

        prevKey = key

        local value = values[index]

        return key, value
    end
end

function x.MapFromPairs(tbl)
    local map = x.Map()

    local indicies = map.Indicies
    local values   = map.Values

    for k, v in pairs(tbl) do
        indicies[k] = table_insert(values, v)
    end

    return map
end

function x.Map()
    return setmetatable({
        Indicies = {},
        Values   = {}
    }, MAP)
end
