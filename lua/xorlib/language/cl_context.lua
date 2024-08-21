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
