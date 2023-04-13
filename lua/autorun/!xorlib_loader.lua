--
-- There is library setup file (lua/xorlib/!.xorlib_setup.lua)
-- which will be included BEFORE "xorlib" directory
-- and all requirers
--
-- It can override xorlib.PreInclude to prevent including files
-- even with xorlib.Dependency
--
-- Define ```xorlib.MANUAL_INCLUDE = true``` to prevent loading
-- "xorlib" and all requirers. It allows to manually include
-- every file
--

xorlib = xorlib or {}
x = xorlib

local PRINT_PREFIX = CLIENT and "CLIENT" or "SERVER"

local USE_XORLIB_FILENAME	= "!.use_xorlib.lua"
local XORLIB_SETUP_FILENAME	= "!.xorlib_setup.lua"

local ignoreIncludes = {}

local function loaderPrint(fmt, ...)
	print(string.format("%s: [xorlib] " .. fmt, PRINT_PREFIX, ...))
end

local function loaderInclude(path)
	loaderPrint("including %s", path)

	include(path)
end

local includers = {
	["cl_"] = function(path)
		if SERVER then
			loaderPrint("including client %s", path)

			AddCSLuaFile(path)
		end

		if CLIENT then
			loaderInclude(path)
		end
	end,

	["sh_"] = function(path)
		if SERVER then
			AddCSLuaFile(path)
		end

		loaderInclude(path)
	end,

	["sv_"] = function(path)
		if SERVER then
			loaderInclude(path)
		end
	end
}

function xorlib.PreInclude(subfolder, filename)
	-- can be overrided to prevent loading files
	return true
end

function xorlib.IsIncluded(subfolder, filename)
	if filename then
		return ignoreIncludes[subfolder .. filename] == true
	else
		return ignoreIncludes[subfolder] == true
	end
end

local function loaderAutoInclude(subfolder, filename)
	-- ignoring requirer
	if filename == USE_XORLIB_FILENAME then return end

	if not xorlib.PreInclude(subfolder, filename) then
		loaderPrint("prevent loading %s/%s", subfolder, filename)

		return
	end

	-- already included
	if xorlib.IsIncluded(subfolder, filename) then return end

	ignoreIncludes[subfolder .. filename] = true

	local prefix = filename:sub(1, 3)
	local path = string.format("%s/%s", subfolder, filename)
	local includer = includers[prefix] or includers["sv_"]

	includer(path)
end

local function sortByShared(files)
	local SHARED_LUA_FILE_PATTERN = "^sh_.+%.lua$"

	table.sort(files, function(a, b)
		local aIsShared = a:match(SHARED_LUA_FILE_PATTERN) ~= nil
		local bIsShared = b:match(SHARED_LUA_FILE_PATTERN) ~= nil

		if aIsShared and bIsShared then return false end
		if aIsShared then return true end

		return false
	end)

	return files
end

local function recursiveInclude(subfolder)
	-- already loaded
	if ignoreIncludes[subfolder] then return end

	ignoreIncludes[subfolder] = true

	local files, dirs = file.Find(string.format("%s/*", subfolder), "LUA")

	if not files or not dirs then
		return loaderPrint("subpath %s is invalid", subfolder)
	end

	local LUA_EXT_PATTERN = "%.lua$"

	for _, filename in ipairs(sortByShared(files)) do
		if filename ~= USE_XORLIB_FILENAME then
			if filename:match(LUA_EXT_PATTERN) then
				loaderAutoInclude(subfolder, filename)
			else
				loaderPrint("unknown file type: %s/%s", subfolder, filename)
			end
		end
	end

	for _, dir in ipairs(dirs) do
		recursiveInclude(subfolder .. "/" .. dir)
	end
end

local function runSetup()
	local setupFilepath = "xorlib/" .. XORLIB_SETUP_FILENAME

	if file.Exists(setupFilepath, "LUA") then
		includers["sh_"](setupFilepath)
	end
end

local function findRequirers()
	local requirers = {}

	do
		local _, dirs = file.Find("*", "LUA")

		for i, dir in ipairs(dirs) do
			if file.Exists(string.format("%s/%s", dir, USE_XORLIB_FILENAME), "LUA") then
				table.insert(requirers, dir)
			end
		end
	end

	return requirers
end

function xorlib.Dependency(subfolder, filename)
	if not filename then
		-- include whole directory
		recursiveInclude(subfolder)
	else
		-- include just one file
		loaderAutoInclude(subfolder, filename)
	end

	return xorlib.IsIncluded(subfolder, filename)
end

function xorlib.IncludeAll()
	ignoreIncludes = {}

	runSetup()

	if not xorlib.MANUAL_INCLUDE then
		recursiveInclude("xorlib")

		for i, dir in ipairs(findRequirers()) do
			loaderPrint("including requirer: %s", dir)

			if SERVER then
				AddCSLuaFile(string.format("%s/%s", dir, USE_XORLIB_FILENAME))
			end

			recursiveInclude(dir)
		end
	end
end

timer.Create("xorlib anti replacement", 0, 0, function()
	if x ~= xorlib then
		ErrorNoHalt("Some addon replaced xorlib (_G.x) library!")

		x = xorlib
	end
end)

if SERVER then
	local function processReincludeAllCommand(ply)
		if
			IsValid(ply) and
			not ply:IsSuperAdmin()
		then
			loaderPrint("player %s [%s] attempted to reinclude all files!", ply:Nick(), ply:SteamID())

			ply:Kick("не стоит этого делать...")

			return false
		end

		loaderPrint("reincluding all")

		xorlib.IncludeAll()

		return true
	end

	concommand.Add("reinclude_all_server", processReincludeAllCommand)

	concommand.Add("reinclude_all_shared", function(ply)
		if not processReincludeAllCommand(ply) then return end

		for i, ply in ipairs(player.GetHumans()) do
			ply:ConCommand("reinclude_all_client")
		end
	end)
else
	concommand.Add("reinclude_all_client", function()
		loaderPrint("reincluding all")

		xorlib.IncludeAll()
	end)
end

xorlib.IncludeAll()
