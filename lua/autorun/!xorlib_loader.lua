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

local USE_XORLIB_FILENAME   = "!.use_xorlib.lua"
local XORLIB_SETUP_FILENAME = "!.xorlib_setup.lua"

local LUA_EXT_PATTERN = "%.lua$"

local ignoreIncludes = {}

local function loaderPrint(fmt, ...)
    print(string.format("%s: [xorlib] " .. fmt, PRINT_PREFIX, ...))
end

local function sortByShared(files)
    table.sort(files, function(a, b)
        local aIsShared = xorlib.FindMatchingIncluder(a) == xorlib.SharedIncluder
        local bIsShared = xorlib.FindMatchingIncluder(b) == xorlib.SharedIncluder

        if aIsShared and bIsShared then return false end
        if aIsShared then return true end

        return false
    end)

    return files
end

local function loaderInclude(path)
    loaderPrint("including %s", path)

    include(path)
end

function xorlib.SharedIncluder(path)
    if SERVER then
        loaderPrint("including shared %s", path)

        AddCSLuaFile(path)
    end

    loaderInclude(path)
end

function xorlib.ServerIncluder(path)
    if SERVER then
        loaderPrint("including server %s", path)

        loaderInclude(path)
    end
end

function xorlib.ClientIncluder(path)
    if SERVER then
        loaderPrint("including client %s", path)

        AddCSLuaFile(path)
    end

    if CLIENT then
        loaderInclude(path)
    end
end

function xorlib.AutoIncluder(path)
    local filename = string.GetFileFromFilename(path)
    local includer = xorlib.FindMatchingIncluder(filename)

    if not includer then
        return
    end

    includer(path)
end

xorlib.MatchingIncluders = {
    { Match = "^sh_",      Includer = xorlib.SharedIncluder },
    { Match = "_sh%.lua$", Includer = xorlib.SharedIncluder },

    { Match = "^cl_",      Includer = xorlib.ClientIncluder },
    { Match = "_cl%.lua$", Includer = xorlib.ClientIncluder },

    { Match = "^sv_",      Includer = xorlib.ServerIncluder },
    { Match = "_sv%.lua$", Includer = xorlib.ServerIncluder },
}

function xorlib.FindMatchingIncluder(filename)
    for i, config in ipairs(xorlib.MatchingIncluders) do
        if string.match(filename, config.Match) then
            return config.Includer
        end
    end

    return nil
end

function xorlib.IsIncluded(subpath, filename)
    if filename then
        return ignoreIncludes[subpath .. filename] == true
    else
        return ignoreIncludes[subpath] == true
    end
end

function xorlib.IncludeFile(includer, subpath, filename)
    -- ignoring requirer
    if filename == USE_XORLIB_FILENAME then return end

    if not xorlib.PreInclude(subpath, filename) then
        loaderPrint("prevent loading %s/%s", subpath, filename)

        return
    end

    -- already included
    if xorlib.IsIncluded(subpath, filename) then return end

    local path = string.format("%s/%s", subpath, filename)

    if not file.Exists(path, "LUA") then
        return
    end

    ignoreIncludes[subpath .. filename] = true

    includer(path)
end

function xorlib.RecursiveInclude(includer, subpath)
    -- already loaded
    if ignoreIncludes[subpath] then return end

    ignoreIncludes[subpath] = true

    local files, dirs = file.Find(string.format("%s/*", subpath), "LUA")

    if not files or not dirs then
        return loaderPrint("subpath %s is invalid", subpath)
    end

    for _, filename in ipairs(sortByShared(files)) do
        if
            filename ~= USE_XORLIB_FILENAME and
            string.match(filename, LUA_EXT_PATTERN)
        then
            xorlib.IncludeFile(includer, subpath, filename)
        end
    end

    for _, dir in ipairs(dirs) do
        xorlib.RecursiveInclude(includer, subpath .. "/" .. dir)
    end
end

function xorlib.Dependency(subpath, filename)
    if not filename then
        -- include whole directory
        xorlib.RecursiveInclude(xorlib.AutoIncluder, subpath)
    else
        -- include just one file
        xorlib.IncludeFile(xorlib.AutoIncluder, subpath, filename)
    end

    return xorlib.IsIncluded(subpath, filename)
end

function xorlib.PreInclude(subpath, filename)
    -- can be overrided to prevent loading files
    return true
end

-- xorlib.IncludeAll
do
    local function runSetup()
        local setupFilepath = "xorlib/" .. XORLIB_SETUP_FILENAME

        if file.Exists(setupFilepath, "LUA") then
            xorlib.SharedIncluder(setupFilepath)
        end
    end

    local function findRequirers()
        local requirers = {}

        do
            local _, dirs = file.Find("*", "LUA")

            for _, dir in ipairs(dirs) do
                if file.Exists(string.format("%s/%s", dir, USE_XORLIB_FILENAME), "LUA") then
                    table.insert(requirers, dir)
                end
            end
        end

        return requirers
    end

    function xorlib.IncludeAll()
        ignoreIncludes = {}

        runSetup()

        if not xorlib.MANUAL_INCLUDE then
            xorlib.RecursiveInclude(xorlib.AutoIncluder, "xorlib")

            for _, dir in ipairs(findRequirers()) do
                loaderPrint("including requirer: %s", dir)

                if SERVER then
                    AddCSLuaFile(string.format("%s/%s", dir, USE_XORLIB_FILENAME))
                end

                xorlib.RecursiveInclude(xorlib.AutoIncluder, dir)
            end
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

            return false
        end

        loaderPrint("reincluding all")

        xorlib.IncludeAll()

        return true
    end

    concommand.Add("reinclude_all_server", processReincludeAllCommand)

    concommand.Add("reinclude_all_shared", function(ply)
        if not processReincludeAllCommand(ply) then return end

        for _, ply in ipairs(player.GetHumans()) do
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
