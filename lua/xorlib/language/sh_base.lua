xorlib.Dependency("xorlib/functional", "sh_hotreload.lua")
xorlib.Dependency("xorlib/table",      "sh_enumeration.lua")

xorlib.Dependency("xorlib/language",   "sh_context.lua")

function xorlib.ValidateAllLanguageContexts()
    x.EachValue(xorlib.LanguageContextList, xorlib.LANGUAGE_CONTEXT.ValidateAllLanguages)
end

function xorlib.ChangeLanguageForAllLanguageContexts(newLanguageName)
    for _, ctx in pairs(xorlib.LanguageContextList) do
        if not ctx._Explicit then
            ctx:ChangeLanguage(newLanguageName)
        end
    end
end

function xorlib.IndexAllLanguageContextsPhrases()
    x.EachValue(xorlib.LanguageContextList, xorlib.LANGUAGE_CONTEXT.IndexPhrases)
end

x.EnsureInitialized(function()
    xorlib.IndexAllLanguageContextsPhrases()
    xorlib.ValidateAllLanguageContexts()
end)
