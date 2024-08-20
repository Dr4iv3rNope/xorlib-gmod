xorlib.Dependency("xorlib/networking", "sh_vaargs.lua") -- x.NetWriteVaargs
local XORLIB_USERGROUPS = xorlib.Dependency("xorlib/player", "sh_usergroups.lua") -- x.Get*Players

util.AddNetworkString("xorlib_prettyprint_lang")

function x.PrettyPrintAll(...)
    x.RPCAll("xorlib.PrettyPrint", ...)
end

function x.PrettyPrintOmit(ignore, ...)
    x.RPCOmit(ignore, "xorlib.PrettyPrint", ...)
end

function x.PrettyPrintOnly(sendTo, ...)
    x.RPCOnly(sendTo, "xorlib.PrettyPrint", ...)
end

--[[
    Example:

    x.NetWritePrettyPrintLang(
        "someLanguageContext",
        x.ColorRed,
        { "phrase.name", "phrase arg 1" },
        x.ColorGreen,
        { "phrase.other" },
        x.ColorBlue,
        "not a phrase, just regular text"
    )
]]
function x.NetWritePrettyPrintLang(contextName, ...)
    local context = x.LanguageContextList[contextName]

    x.Assert(context, "Language context \"%s\" doesn't exist", contextName)

    local argc = select("#", ...)

    net.WriteUInt(argc, 8)
    net.WriteString(contextName)

    for i = 1, argc do
        local arg = select(i, ...)

        if
            type(arg) == "table" and
            --[[ HACK: ]] not IsColor(arg)
        then
            net.WriteBool(true) -- phrase

            local phraseID = table.remove(arg, 1)

            context:NetWritePhrase(phraseID, unpack(arg))
        else
            net.WriteBool(false) -- regular value
            net.WriteType(arg)
        end
    end
end

function x.PrettyPrintLangAll(contextName, ...)
    net.Start("xorlib_prettyprint_lang")
    x.NetWritePrettyPrintLang(contextName, ...)
    net.Broadcast()
end

function x.PrettyPrintLangOmit(ignore, contextName, ...)
    net.Start("xorlib_prettyprint_lang")
    x.NetWritePrettyPrintLang(contextName, ...)
    net.SendOmit(ignore)
end

function x.PrettyPrintLangOnly(sendTo, contextName, ...)
    net.Start("xorlib_prettyprint_lang")
    x.NetWritePrettyPrintLang(contextName, ...)
    net.Send(sendTo)
end

if XORLIB_USERGROUPS then
    function x.PrettyPrintAdmins(...)
        x.PrettyPrintOnly(x.GetAdminPlayers(), ...)
    end

    function x.PrettyPrintSuperAdmins(...)
        x.PrettyPrintOnly(x.GetSuperAdminPlayers(), ...)
    end

    function x.PrettyPrintLangAdmins(contextName, ...)
        x.PrettyPrintLangOnly(x.GetAdminPlayers(), contextName, ...)
    end

    function x.PrettyPrintLangSuperAdmins(contextName, ...)
        x.PrettyPrintLangOnly(x.GetSuperAdminPlayers(), contextName, ...)
    end
end

local PLAYER = FindMetaTable("Player")
PLAYER.PrettyPrint = x.PrettyPrintOnly
PLAYER.PrettyPrintLang = x.PrettyPrintLangOnly
