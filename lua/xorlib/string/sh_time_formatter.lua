xorlib.Dependency("xorlib/language")

local floor           = math.floor
local languageContext = x.XorlibLanguageContext

languageContext:DefineLanguagePhrase("time_formatter.seconds")
languageContext:DefineLanguagePhrase("time_formatter.minutes")
languageContext:DefineLanguagePhrase("time_formatter.hours")
languageContext:DefineLanguagePhrase("time_formatter.days")
languageContext:DefineLanguagePhrase("time_formatter.weeks")

x.FORMAT_TIME_SECONDS = 0
x.FORMAT_TIME_MINUTES = 1
x.FORMAT_TIME_HOURS   = 2
x.FORMAT_TIME_DAYS    = 3
x.FORMAT_TIME_WEEKS   = 4

x.TimeFormatters = {
    [x.FORMAT_TIME_SECONDS] = { Div = 60, Phrase = "time_formatter.seconds" },
    [x.FORMAT_TIME_MINUTES] = { Div = 60, Phrase = "time_formatter.minutes" },
    [x.FORMAT_TIME_HOURS]   = { Div = 24, Phrase = "time_formatter.hours"   },
    [x.FORMAT_TIME_DAYS]    = { Div = 7,  Phrase = "time_formatter.days"    },
    [x.FORMAT_TIME_WEEKS]   = { Div = 7,  Phrase = "time_formatter.weeks"   },
}

local formatters = x.TimeFormatters

function x.FormatTime(time, formatType)
    local str  = ""
    local temp = time

    for i = 0, formatType do
        local formatter = formatters[i]
        local isLast    = i == formatType
        local amount

        if formatter.Div then
            if isLast then
                amount = temp
            else
                amount = floor(temp % formatter.Div)
                temp   = floor(temp / formatter.Div)
            end
        else
            amount = temp
        end

        str = amount ..
              " " ..
              languageContext:Phrase(formatter.Phrase) ..
              str

        if not isLast then
            str = " " .. str
        end
    end

    return str
end

function x.FormatTimeOnly(time, formatType)
    local amount
    local temp = time

    for i = 0, formatType do
        local formatter = formatters[i]
        local isLast    = i == formatType

        if formatter.Div then
            if isLast then
                amount = temp
            else
                amount = floor(temp % formatter.Div)
                temp   = floor(temp / formatter.Div)
            end
        else
            amount = temp
        end
    end

    return amount .. " " .. languageContext:Phrase(formatters[formatType].Phrase)
end