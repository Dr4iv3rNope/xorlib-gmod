xorlib.Dependency("xorlib/console", "sh_print.lua")

xorlib.LANGUAGE         = xorlib.LANGUAGE or {}
xorlib.LANGUAGE.__index = xorlib.LANGUAGE

local string_gsub = string.gsub

local PLACEHOLDERS_PATTERN = "{(%d)}"

function xorlib.LANGUAGE:Phrase(phraseID, text)
	self.Phrases[phraseID] = text

	return self
end

function xorlib.LANGUAGE:Get(phraseID, a1, a2, a3, a4, a5, a6, a7, a8, a9)
	local text = self.Phrases[phraseID]

	if a1 then
		local lookupTable = {
			["1"] = a1,
			["2"] = a2,
			["3"] = a3,
			["4"] = a4,
			["5"] = a5,
			["6"] = a6,
			["7"] = a7,
			["8"] = a8,
			["9"] = a9,
		}

		text = string_gsub(text, PLACEHOLDERS_PATTERN, lookupTable)
	end

	return text
end

function xorlib.LANGUAGE:GetEx(phraseID, a1, a2, a3, a4, a5, a6, a7, a8, a9)
	local text = self.Phrases[phraseID]

	if a1 then
		local function tryGetPhrase(argPhrase)
			if not argPhrase then
				return nil
			end

			return self.Phrases[argPhrase] or argPhrase
		end

		local lookupTable = {
			["1"] = tryGetPhrase(a1),
			["2"] = tryGetPhrase(a2),
			["3"] = tryGetPhrase(a3),
			["4"] = tryGetPhrase(a4),
			["5"] = tryGetPhrase(a5),
			["6"] = tryGetPhrase(a6),
			["7"] = tryGetPhrase(a7),
			["8"] = tryGetPhrase(a8),
			["9"] = tryGetPhrase(a9),
		}

		text = string_gsub(text, PLACEHOLDERS_PATTERN, lookupTable)
	end

	return text
end

function xorlib.Language(name)
    return setmetatable({
        Name    = name,
        Phrases = {}
    }, xorlib.LANGUAGE)
end
