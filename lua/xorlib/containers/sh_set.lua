xorlib.Dependency("xorlib/table", "sh_remove.lua")

local table_insert = table.insert
local table_remove = table.remove

xorlib.SET = xorlib.SET or {}

local SET = xorlib.SET
SET.__index = SET

function SET:Length()
    return #self.Values
end

function SET:Has(key)
    return self.Keys[key] ~= nil
end

function SET:Index(value)
    return self.Keys[value]
end

function SET:BulkEdit()
    if self._BulkEdit then return end

    self._BulkEdit = true
    self._BulkReconstructFromIndex = #self.Values + 1
end

function SET:CommitBulkEdit()
    if not self._BulkEdit then return end

    self._BulkEdit = nil

    self:Reconstruct(self._BulkReconstructFromIndex)

    self._BulkReconstructFromIndex = nil
end

function SET:Insert(a, b)
    local keys   = self.Keys
    local values = self.Values

    local pos, value

    if b == nil then
        pos   = #values + 1
        value = a
    else
        pos   = a
        value = b
    end

    local index = keys[value]

    if index ~= nil then
        if index ~= pos then
            -- if index is different, move value

            values[index] = nil
        else
            -- if insert index is same, override value
            values[index] = value

            return pos
        end
    end

    keys[value] = table_insert(values, pos, value)

    self:Reconstruct(pos + 1)

    return pos
end

function SET:Remove(pos)
    local keys   = self.Keys
    local values = self.Values

    local value = values[pos]
    if value == nil then return end

    table_remove(values, pos)
    keys[value] = nil

    self:Reconstruct(pos)

    return value
end

function SET:Delete(key)
    local keys   = self.Keys
    local values = self.Values

    local index = keys[key]
    if index == nil then return end

    table_remove(values, index)
    keys[key] = nil

    self:Reconstruct(index)
end

function SET:Clear(dontRecreateTables)
    if dontRecreateTables then
        x.EmptyPairs(self.Keys)
        x.EmptySequence(self.Values)
    else
        self.Keys   = {}
        self.Values = {}
    end
end

function SET:Reconstruct(from)
    if self._BulkEdit then
        if self._BulkReconstructFromIndex > from then
            self._BulkReconstructFromIndex = from
        end

        return
    end

    local keys   = self.Keys
    local values = self.Values

    for i = from, #values do
        local v = values[i]

        keys[v] = i
    end
end

function x.SetFromSequence(tbl)
    local list = setmetatable({
        Keys   = {},
        Values = tbl
    }, SET)

    list:Reconstruct(1)

    return list
end

-- TODO: legacy fallback. remove me!
x.SetFromSequential = x.SetFromSequence

function x.Set()
    return setmetatable({
        Keys   = {},
        Values = {}
    }, SET)
end
