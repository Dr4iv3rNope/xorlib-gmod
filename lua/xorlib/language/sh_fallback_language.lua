xorlib.Dependency("xorlib/language", "sh_language.lua")

xorlib.FallbackLanguage = xorlib.Language("<FALLBACK_LANGUAGE>")

setmetatable(xorlib.FallbackLanguage.Phrases, {
    __index = function(_, phraseID)
        return phraseID
    end
})
