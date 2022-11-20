function x.Assert(value, fmt, ...)
	if not value then
		x.Error(fmt or "assertation failed!", ...)
	end

	return value
end
