local pairs = pairs

function x.SequenceHasValue(tbl, value)
	for i = 1, #tbl do
		if tbl[i] == value then
			return true
		end
	end

	return false
end

function x.PairsHasKey(tbl, value)
	for k, v in pairs(tbl) do
		if k == value then
			return true
		end
	end

	return false
end

function x.PairsHasValue(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return true
		end
	end

	return false
end
