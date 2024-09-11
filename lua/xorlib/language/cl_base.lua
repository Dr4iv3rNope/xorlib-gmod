function xorlib.SyncGmodLanguageForAllLanguageContexts()
    local lang = GetConVar("gmod_language"):GetString()

    xorlib.ChangeLanguageForAllLanguageContexts(lang)
end

x.EnsureInitialized(function()
    xorlib.SyncGmodLanguageForAllLanguageContexts()
end)

cvars.AddChangeCallback("gmod_language", function(_, _, newLanguageName)
    xorlib.ChangeLanguageForAllLanguageContexts(newLanguageName)
end, "xorlib language")
