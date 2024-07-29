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

function MAP:Key(value)
    return self.KeyMap[value]
end

function MAP:Set(key, value)
    local indices = self.Indices
    local values  = self.Values
    local keyMap  = self.KeyMap

    local index = indices[key]

    if index ~= nil then
        -- override value
        values[index] = value
    else
        -- insert new value
        indices[key] = table_insert(values, value)
        keyMap[value] = key
    end
end

function MAP:Delete(key)
    local indices = self.Indices
    local values  = self.Values
    local keyMap  = self.KeyMap

    local index = indices[key]
    if index == nil then return end

    local value = table_remove(values, index)

    indices[key] = nil
    keyMap[value] = nil

    self:Reconstruct(index)

    return value
end

function MAP:Clear(dontRecreateTables)
    if dontRecreateTables then
        x.EmptyPairs(self.Indices)
        x.EmptySequence(self.Values)
        x.EmptyPairs(self.KeyMap)
    else
        self.Indices = {}
        self.Values  = {}
        self.KeyMap  = {}
    end
end

function MAP:BulkEdit()
    if self._BulkEdit then return end

    self._BulkEdit = true
    self._BulkReconstructFromIndex = #self.Values + 1
end

function MAP:CommitBulkEdit()
    if not self._BulkEdit then return end

    self._BulkEdit = nil

    self:Reconstruct(self._BulkReconstructFromIndex)

    self._BulkReconstructFromIndex = nil
end

function MAP:Reconstruct(from)
    if self._BulkEdit then
        if self._BulkReconstructFromIndex > from then
            self._BulkReconstructFromIndex = from
        end

        return
    end

    local indices = self.Indices
    local values  = self.Values
    local keyMap  = self.KeyMap

    for i = from, #values do
        local v = values[i]
        local k = keyMap[v]

        indices[k] = i
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
    local keyMap  = map.KeyMap

    for k, v in pairs(tbl) do
        indices[k] = table_insert(values, v)
        keyMap[v] = k
    end

    return map
end

function x.Map()
    -- TODO: remove deprecated "Indicies" later
    local indices = {}

    return setmetatable({
        Indices = indices,
        Values  = {},
        KeyMap  = {},

        _BulkEdit = nil,
        _BulkReconstructFromIndex = nil,

        -- HACK: deprecated
        Indicies = indices,
    }, MAP)
end
