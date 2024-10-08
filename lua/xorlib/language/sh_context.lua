xorlib.Dependency("xorlib/assert",     "sh_assert.lua")
xorlib.Dependency("xorlib/console",    "sh_print.lua")
xorlib.Dependency("xorlib/functional", "sh_bind.lua")
xorlib.Dependency("xorlib/table",      "sh_enumeration.lua")
xorlib.Dependency("xorlib/networking", "sh_vaargs.lua")
xorlib.Dependency("xorlib/language",   "sh_language.lua")

xorlib.LANGUAGE_CONTEXT         = xorlib.LANGUAGE_CONTEXT or {}
xorlib.LANGUAGE_CONTEXT.__index = xorlib.LANGUAGE_CONTEXT

xorlib.LanguageContextList      = xorlib.LanguageContextList or {}

function xorlib.LANGUAGE_CONTEXT:DefineLanguagePhrase(phraseID)
    self.RequiredPhrases[phraseID] = self.RequiredPhrases[phraseID] or -1
end

function xorlib.LANGUAGE_CONTEXT:Phrase(phraseID, ...)
    return self.ActiveLanguage:Get(phraseID, ...)
end

function xorlib.LANGUAGE_CONTEXT:PhraseEx(phraseID, ...)
    return self.ActiveLanguage:GetEx(phraseID, ...)
end

function xorlib.LANGUAGE_CONTEXT:GetPhraseIndex(phraseID)
    return self.RequiredPhrases[phraseID]
end

function xorlib.LANGUAGE_CONTEXT:GetPhraseID(phraseIndex)
    return self.IndexedPhrases[phraseIndex]
end

function xorlib.LANGUAGE_CONTEXT:_NetWritePhraseEx(phraseID, isExtended, ...)
    local phraseIndex = self:GetPhraseIndex(phraseID)

    x.Assert(phraseIndex,
             "No phrase \"%s\" in context \"%s\"",
             phraseID,
             self.Name)

    net.WriteUInt(phraseIndex, 32)
    net.WriteBool(isExtended)
    x.NetWriteVaargs(...)
end

function xorlib.LANGUAGE_CONTEXT:NetWritePhrase(phraseID, ...)
    self:_NetWritePhraseEx(phraseID, false, ...)
end

function xorlib.LANGUAGE_CONTEXT:NetWritePhraseEx(phraseID, ...)
    self:_NetWritePhraseEx(phraseID, true, ...)
end

function xorlib.LANGUAGE_CONTEXT:NetReadPhrase(disallowExtended)
    local phraseIndex = net.ReadUInt(32)
    local isExtended  = net.ReadBool()
    local phraseID    = self:GetPhraseID(phraseIndex)

    if disallowExtended or not isExtended then
        return self:Phrase(phraseID, x.NetReadVaargsUnpacked())
    else
        return self:PhraseEx(phraseID, x.NetReadVaargsUnpacked())
    end
end

function xorlib.LANGUAGE_CONTEXT:OnLanguageChanged(newLanguage, oldLanguage)
    -- for override
end

function xorlib.LANGUAGE_CONTEXT:HasLanguage(name)
    return self.AvailableLanguages[name] ~= nil
end

function xorlib.LANGUAGE_CONTEXT:GetLanguage(name)
    x.Assert(self:HasLanguage(name),
             "No language \"%s\" in context \"%s\"",
             name,
             self.Name)

    return self.AvailableLanguages[name]
end

function xorlib.LANGUAGE_CONTEXT:ChangeLanguage(newLanguageName)
    local newLanguage

    if not self:HasLanguage(newLanguageName) then
        if self._FallbackTo then
            newLanguage = self.AvailableLanguages[self._FallbackTo]

            if not newLanguage then
                x.ErrorNoHalt(
                    "Language context \"%s\" has invalid fallback language (%s)",
                    self.Name,
                    self._FallbackTo
                )
            end
        end

        if not newLanguage then
            newLanguage = xorlib.FallbackLanguage
        end

        x.Warn(
            "Language context \"%s\" doesn't have language \"%s\", fallback to \"%s\"!",
            self.Name,
            newLanguageName,
            newLanguage.Name
        )
    else
        newLanguage = self.AvailableLanguages[newLanguageName]
    end

    local oldLanguage = self.ActiveLanguage

    if newLanguage == oldLanguage then
        return
    end

    self.ActiveLanguage = newLanguage

    self:OnLanguageChanged(newLanguage, oldLanguage)
end

function xorlib.LANGUAGE_CONTEXT:DefineLanguage(languageName)
    local language = xorlib.Language(languageName)

    self.AvailableLanguages[languageName] = language

    return language
end

function xorlib.LANGUAGE_CONTEXT:ValidateLanguage(language)
    for phraseID, _ in pairs(self.RequiredPhrases) do
        if not language.Phrases[phraseID] then
            x.Warn("Context \"%s\": language \"%s\" doesn't have phrase id: \"%s\"",
                   self.Name,
                   language.Name,
                   phraseID)
        end
    end

    for phraseID, _ in pairs(language.Phrases) do
        if not self.RequiredPhrases[phraseID] then
            x.Warn("Context \"%s\": language \"%s\" contains unknown phrase id: \"%s\"",
                   self.Name,
                   language.Name,
                   phraseID)
        end
    end
end

function xorlib.LANGUAGE_CONTEXT:ValidateAllLanguages()
    x.EachValue(self.AvailableLanguages,
                x.Bind(self.ValidateLanguage, self, x._1))
end

function xorlib.LANGUAGE_CONTEXT:IndexPhrases()
    local index = 0

    for phraseID, _ in SortedPairs(self.RequiredPhrases) do
        self.RequiredPhrases[phraseID] = index
        self.IndexedPhrases[index]     = phraseID

        index = index + 1
    end
end

-- Ignores xorlib.ChangeLanguageForAllLanguageContexts
function xorlib.LANGUAGE_CONTEXT:Explicit()
    self._Explicit = true

    return self
end

function xorlib.LANGUAGE_CONTEXT:FallbackTo(languageName)
    self._FallbackTo = languageName

    return self
end

function xorlib.LanguageContext(name)
    local context = setmetatable({
        Name               = name,

        AvailableLanguages = {},
        ActiveLanguage     = xorlib.FallbackLanguage,

        RequiredPhrases    = {},
        IndexedPhrases     = {},

        _Explicit = false,
        _FallbackTo = nil,
    }, xorlib.LANGUAGE_CONTEXT)

    xorlib.LanguageContextList[name] = context

    return context
end
