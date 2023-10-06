xorlib.Dependency("xorlib/functional", "sh_hotreload.lua")
xorlib.Dependency("xorlib/table",      "sh_enumeration.lua")

xorlib.Dependency("xorlib/language",   "sh_context.lua")
xorlib.Dependency("xorlib/language",   "sh_language.lua")

function xorlib.ValidateAllLanguageContexts()
    x.EachValue(xorlib.LanguageContextList, xorlib.LANGUAGE_CONTEXT.ValidateAllLanguages)
end

x.EnsureInitialized(xorlib.ValidateAllLanguageContexts)
