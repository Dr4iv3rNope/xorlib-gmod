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
		addLevel = 1
	end

	addLevel = addLevel + 1

	return debug_getinfo(addLevel, flags)
end

local UNKNOWN_SOURCE = {
	source = "<unknown>",
	linedefined = -1
}

function x.CalleePath(addLevel)
	addLevel = (addLevel or 1) + 1

	local info = debug_getinfo(addLevel, "Sn") or UNKNOWN_SOURCE

	return (info.name or "<unknown>") .. ":" .. info.source .. ":" .. info.linedefined
end
