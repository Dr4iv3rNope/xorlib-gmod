xorlib.Dependency("xorlib/table", "sh_remove.lua")

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
    return self.Indices[key] ~= nil
end

function MAP:Index(key)
    return self.Indices[key]
end

function MAP:Get(key)
    return self.Values[self.Indices[key]]
end

function MAP:Set(key, value)
    local indices = self.Indices
    local values  = self.Values

    local index = indices[key]

    if index ~= nil then
        -- override value
        values[index] = value
    else
        -- insert new value
        indices[key] = table_insert(values, value)
    end
end

function MAP:Delete(key)
    local indices = self.Indices
    local values  = self.Values

    local index = indices[key]
    if index == nil then return end

    local value = table_remove(values, index)

    indices[key] = nil

    return value
end

function MAP:Clear(dontRecreateTables)
    if dontRecreateTables then
        x.EmptyPairs(self.Indices)
        x.EmptySequence(self.Values)
    else
        self.Indices = {}
        self.Values  = {}
    end
end

function MAP:Iterate()
    local indices = self.Indices
    local values  = self.Values

    local prevKey = nil

    return function()
        local key, index = next(indices, prevKey)

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

    local indices = map.Indices
    local values  = map.Values

    for k, v in pairs(tbl) do
        indices[k] = table_insert(values, v)
    end

    return map
end

function x.Map()
    -- TODO: remove deprecated "Indicies" later
    local indices = {}

    return setmetatable({
        Indices = indices,
        Values  = {},

        -- HACK: deprecated
        Indicies = indices,
    }, MAP)
end
