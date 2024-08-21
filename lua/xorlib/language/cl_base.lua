xorlib.Dependency("xorlib/language", "cl_language.lua")
xorlib.Dependency("xorlib/language", "cl_fallback_language.lua")

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

function xorlib.SyncGmodLanguageForAllLanguageContexts()
    local lang = GetConVar("gmod_language"):GetString()

    xorlib.ChangeLanguageForAllLanguageContexts(lang)
end

x.EnsureInitialized(function()
    xorlib.ValidateAllLanguageContexts()
    xorlib.SyncGmodLanguageForAllLanguageContexts()
end)

cvars.AddChangeCallback("gmod_language", function(_, _, newLanguageName)
    xorlib.ChangeLanguageForAllLanguageContexts(newLanguageName)
end, "xorlib language")
