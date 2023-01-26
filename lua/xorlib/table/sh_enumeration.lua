local pairs = pairs

function x.EachSequence(tbl, callback)
	for i = 1, #tbl do
		callback(tbl[i])
	end

	return tbl
end

function x.EachPairs(tbl, callback)
	for k, v in pairs(tbl) do
		callback(k, v)
	end

	return tbl
end

function x.EachKey(tbl, callback)
	for k, v in pairs(tbl) do
		callback(k)
	end

	return tbl
end

function x.EachValue(tbl, callback)
	for k, v in pairs(tbl) do
		callback(v)
	end

	return tbl
end
