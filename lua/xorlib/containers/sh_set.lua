local rawget		= rawget
local rawset		= rawset
local select		= select
local table_insert	= table.insert
local table_remove	= table.remove

local SET = {}

function SET.__index(tbl, k)
	return rawget(SET, k) or rawget(tbl, "values")[k]
end

function SET.__newindex(tbl, index, value)
	local values = rawget(tbl, "values")

	if values[index] == nil then
		SET.Insert(tbl, value)

		return
	end

	rawset(values, index, value)
end

function SET:Length()
	return #rawget(self, "values")
end

function SET:Has(key)
	return rawget(self, "keys")[key] ~= nil
end

function SET:Insert(...)
	local keys, values = rawget(self, "keys"), rawget(self, "values")
	local length = #values
	local pos, value

	if select("#", ...) == 1 then
		pos = length + 1
		value = select(1, ...)
	else
		pos = select(1, ...)
		value = select(2, ...)
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
	local keys, values = rawget(self, "keys"), rawget(self, "values")

	local value = values[pos]
	if value == nil then return end

	table_remove(values, pos)
	keys[value] = nil

	self:Reconstruct(pos)

	return value
end

function SET:Delete(key)
	local keys, values = rawget(self, "keys"), rawget(self, "values")

	local index = keys[key]
	if index == nil then return end

	table_remove(values, index)
	keys[key] = nil

	self:Reconstruct(index)
end

function SET:Reconstruct(from)
	local keys, values = rawget(self, "keys"), rawget(self, "values")

	for i = from, #values do
		local v = values[i]

		keys[v] = i
	end
end

function x.SetFromSequential(tbl)
	local list = setmetatable({
		keys = {},
		values = tbl
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
		keys = keys,
		values = values
	}, SET)
end

function x.Set()
	return setmetatable({
		keys = {},
		values = {}
	}, SET)
end
