xorlib.Dependency("xorlib/language", "sh_language.lua")

xorlib.FallbackLangauge = xorlib.Language("<FALLBACK_LANGUAGE>")

setmetatable(xorlib.FallbackLangauge.Phrases, {
    __index = function(_, phraseID)
        return phraseID
    end
})
