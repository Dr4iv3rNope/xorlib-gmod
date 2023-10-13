xorlib.Dependency("xorlib/networking",  "sh_vaargs.lua")      -- x.NetReadVaargs
xorlib.Dependency("xorlib/prettyprint", "sh_prettyprint.lua") -- x.PrettySequence

function x.PrettyPrintData(data)
    chat.AddText(unpack(x.PrettySequence(data)))
end

function x.PrettyPrint(...)
    x.PrettyPrintData({ ... })
end

net.Receive("xorlib_prettyprint", function()
    local data = x.NetReadVaargs()

    x.PrettyPrintData(data)
end)
