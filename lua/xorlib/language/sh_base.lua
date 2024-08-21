xorlib.Dependency("xorlib/functional", "sh_hotreload.lua")
xorlib.Dependency("xorlib/table",      "sh_enumeration.lua")

xorlib.Dependency("xorlib/language",   "sh_context.lua")

function xorlib.IndexAllLanguageContextsPhrases()
    x.EachValue(xorlib.LanguageContextList, xorlib.LANGUAGE_CONTEXT.IndexPhrases)
end

x.EnsureInitialized(function()
    xorlib.IndexAllLanguageContextsPhrases()
end)
