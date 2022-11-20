xorlib.Dependency("xorlib/functional", "sh_getters.lua") -- X.CalleePath

local string_format			= string.format
local MsgC					= MsgC
local error					= error
local ErrorNoHalt			= ErrorNoHalt
local ErrorNoHaltWithStack	= ErrorNoHaltWithStack

local function formattedCalleePath()
	return string_format("[%s] ", x.CalleePath(3))
end

function x.Print(fmt, ...)
	MsgC(x.ColorWhite, formattedCalleePath(), x.ColorGray, string_format(fmt .. "\n", ...))
end

function x.Warn(fmt, ...)
	MsgC(x.ColorOrange, formattedCalleePath(), "Warning: ", x.ColorGray, string_format(fmt .. "\n", ...))
end

function x.Error(fmt, ...)
	local msg = string_format(fmt .. "\n", ...)

	MsgC(x.ColorLightRed, formattedCalleePath(), x.ColorRed, "Error: ", x.ColorGray, msg)
	error(msg)
end

function x.ErrorNoHalt(fmt, ...)
	local msg = string_format(fmt .. "\n", ...)

	MsgC(x.ColorLightRed, formattedCalleePath(), x.ColorRed, "Error: ", x.ColorGray, msg)
	ErrorNoHalt(msg)
end

function x.ErrorNoHaltWithStack(fmt, ...)
	local msg = string_format(fmt .. "\n", ...)

	MsgC(x.ColorLightRed, formattedCalleePath(), x.ColorRed, "Error: ", x.ColorGray, msg)
	ErrorNoHaltWithStack(msg)
end

