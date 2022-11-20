local table_remove	= table.remove
local pairs			= pairs

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
			newTable[#newTable] = v
		end
	end

	return newTable
end

function x.FilterPairs(tbl, callback)
	for k, v in pairs(tbl) do
		if not callback(v) then
			tbl[k] = nil
		end
	end

	return tbl
end

function x.FilterCopyPairs(tbl, callback)
	local newTable = {}

	for k, v in pairs(tbl) do
		if callback(v) then
			newTable[k] = v
		end
	end

	return newTable
end
