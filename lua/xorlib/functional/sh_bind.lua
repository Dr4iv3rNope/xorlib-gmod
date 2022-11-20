local select = select
local unpack = unpack

function x.Bind(func, ...)
	x.ExpectFunction(func)

	if select("#", ...) == 0 then return func end

	local args = { ... }

	return function()
		return func(unpack(args))
	end
end

function x.BindMeta(meta, name, ...)
	return x.Bind(x.Meta(meta, name), ...)
end
