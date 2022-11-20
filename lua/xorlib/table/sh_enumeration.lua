local pairs = pairs

function x.EachSequence(tbl, callback)
	for i = 1, #tbl do
		callback(tbl[i])
	end
end

function x.EachPairs(tbl, callback)
	for k, v in pairs(tbl) do
		callback(v)
	end
end
