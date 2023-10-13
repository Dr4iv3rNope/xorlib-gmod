xorlib.Dependency("xorlib/networking", "sh_vaargs.lua") -- x.NetWriteVaargs
local XORLIB_USERGROUPS = xorlib.Dependency("xorlib/player", "sh_usergroups.lua") -- x.Get*Players

util.AddNetworkString("xorlib_prettyprint")

function x.PrettyPrintAll(...)
    net.Start("xorlib_prettyprint")
    x.NetWriteVaargs(...)
    net.Broadcast()
end

function x.PrettyPrintOmit(ignore, ...)
    net.Start("xorlib_prettyprint")
    x.NetWriteVaargs(...)
    net.SendOmit(ignore)
end

function x.PrettyPrintOnly(sendTo, ...)
    net.Start("xorlib_prettyprint")
    x.NetWriteVaargs(...)
    net.Send(sendTo)
end

if XORLIB_USERGROUPS then
    function x.PrettyPrintAdmins(...)
        x.PrettyPrintOnly(x.GetAdminPlayers(), ...)
    end

    function x.PrettyPrintSuperAdmins(...)
        x.PrettyPrintOnly(x.GetSuperAdminPlayers(), ...)
    end
end

local PLAYER = FindMetaTable("Player")
PLAYER.PrettyPrint = x.PrettyPrintOnly
