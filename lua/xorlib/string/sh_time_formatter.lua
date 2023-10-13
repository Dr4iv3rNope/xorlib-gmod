local floor = math.floor

x.FORMAT_TIME_SECONDS = 0
x.FORMAT_TIME_MINUTES = 1
x.FORMAT_TIME_HOURS   = 2
x.FORMAT_TIME_DAYS    = 3
x.FORMAT_TIME_WEEKS   = 4

local formatters = {
    [x.FORMAT_TIME_SECONDS] = { Div = 60, Phrase = "сек." },
    [x.FORMAT_TIME_MINUTES] = { Div = 60, Phrase = "м." },
    [x.FORMAT_TIME_HOURS]   = { Div = 24, Phrase = "ч." },
    [x.FORMAT_TIME_DAYS]    = { Div = 7,  Phrase = "д." },
    [x.FORMAT_TIME_WEEKS]   = { Div = 7,  Phrase = "н." },
}

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

        str = amount .. " " .. formatter.Phrase .. str

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

    return amount .. " " .. formatters[formatType].Phrase
end