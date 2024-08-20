xorlib.Dependency("xorlib/networking",  "sh_vaargs.lua")      -- x.NetReadVaargs
xorlib.Dependency("xorlib/prettyprint", "sh_prettyprint.lua") -- x.PrettyVaargs

-- TODO: deprecated. Use `x.PrettyPrint(unpack(data))`
function x.PrettyPrintData(data)
    x.PrettyPrint(unpack(data))
end

function x.PrettyPrint(...)
    chat.AddText(x.PrettyVaargs(...))
end

local function internalNetReadPrettyPrintLang(context, argc)
    if argc == 0 then return end

    local isPhrase = net.ReadBool()

    if isPhrase then
        return context:NetReadPhrase(), internalNetReadPrettyPrintLang(context, argc - 1)
    else
        return x.PrettyValue(net.ReadType()), internalNetReadPrettyPrintLang(context, argc - 1)
    end
end

function x.NetReadPrettyPrintLang()
    local argc = net.ReadUInt(8)
    local contextName = net.ReadString()

    local context = x.LanguageContextList[contextName]

    x.Assert(context, "Language context \"%s\" doesn't exist", contextName)

    return internalNetReadPrettyPrintLang(context, argc)
end

net.Receive("xorlib_prettyprint_lang", function()
    chat.AddText(x.NetReadPrettyPrintLang())
end)
