local table_remove	= table.remove
local pairs			= pairs

function x.RemoveSequenceValue(tbl, value)
	for i = 1, #tbl do
		if tbl[i] == value then
			table_remove(tbl, i)

			break
		end
	end

	return tbl
end

function x.RemovePairsValue(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			tbl[k] = nil

			break
		end
	end

	return tbl
end

function x.EmptySequence(tbl)
	for i = 1, #tbl do
		tbl[i] = nil
	end

	return tbl
end

function x.EmptyPairs(tbl)
	for k, v in pairs(tbl) do
		tbl[k] = nil
	end

	return tbl
end
