local table_insert = table.insert
local table_remove = table.remove

local SET = {}
SET.__index = SET

function SET:Length()
	return #self.Values
end

function SET:Has(key)
	return self.Keys[key] ~= nil
end

function SET:Insert(a, b)
	local keys, values = self.Keys, self.Values
	local pos, value

	if b == nil then
		pos = #values + 1
		value = a
	else
		pos = a
		value = b
	end

	local index = keys[value]

	if index ~= nil then
		if index ~= pos then
			-- if index is different, move value

			self:Remove(index)
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
	local keys, values = self.Keys, self.Values

	local value = values[pos]
	if value == nil then return end

	table_remove(values, pos)
	keys[value] = nil

	self:Reconstruct(pos)

	return value
end

function SET:Delete(key)
	local keys, values = self.Keys, self.Values

	local index = keys[key]
	if index == nil then return end

	table_remove(values, index)
	keys[key] = nil

	self:Reconstruct(index)
end

function SET:Reconstruct(from)
	local keys, values = self.Keys, self.Values

	for i = from, #values do
		local v = values[i]

		keys[v] = i
	end
end

function x.SetFromSequential(tbl)
	local list = setmetatable({
		Keys = {},
		Values = tbl
	}, SET)

	list:Reconstruct(1)

	return list
end

function x.SetFromKeys(tbl)
	local keys, values = {}, {}

	for k, v in pairs(tbl) do
		keys[k] = table_insert(values, v)
	end

	return setmetatable({
		Keys = keys,
		Values = values
	}, SET)
end

function x.Set()
	return setmetatable({
		Keys = {},
		Values = {}
	}, SET)
end
