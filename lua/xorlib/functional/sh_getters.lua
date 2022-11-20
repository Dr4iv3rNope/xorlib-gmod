local debug_getinfo = debug.getinfo

local _R = debug.getregistry()

function x.Meta(meta, name)
	return _R[meta][name]
end

function x.Callee(addLevel, flags)
	if addLevel then
		-- make level relative to callee

		addLevel = addLevel - 1
	else
		addLevel = 0
	end

	addLevel = addLevel + 3

	return debug_getinfo(addLevel, flags)
end

function x.CalleePath(addLevel)
	addLevel = (addLevel or 0) + 3

	local info = debug_getinfo(addLevel, "S")

	return info.source .. ":" .. info.linedefined
end
