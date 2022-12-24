local floor = math.floor

x.FORMAT_TIME_SECONDS	= 0
x.FORMAT_TIME_MINUTES	= 1
x.FORMAT_TIME_HOURS		= 2
x.FORMAT_TIME_DAYS		= 3
x.FORMAT_TIME_WEEKS		= 4

local formatters = {
	[x.FORMAT_TIME_SECONDS]	= { div = 60, str = "сек." },
	[x.FORMAT_TIME_MINUTES]	= { div = 60, str = "м." },
	[x.FORMAT_TIME_HOURS]	= { div = 24, str = "ч." },
	[x.FORMAT_TIME_DAYS]	= { div = 7, str = "д." },
	[x.FORMAT_TIME_WEEKS]	= { div = 7, str = "н." },
}

function x.FormatTime(time, formatType)
	local str = ""
	local temp = time

	for i = 0, formatType do
		local formatter = formatters[i]
		local isLast = i == formatType
		local amount

		if formatter.div then
			amount = floor(temp % formatter.div)

			if not isLast then
				temp = floor(temp / formatter.div)
			end
		else
			amount = temp
		end

		str = amount .. " " .. formatter.str .. str

		if not isLast then
			str = " " .. str
		end
	end

	return str
end

function x.FormatTimeOnly(time, formatType)
	local amount = time

	for i = 0, formatType do
		local formatter = formatters[i]

		if formatter.div then
			amount = floor(amount / formatter.div)
		end
	end

	return amount .. " " .. formatters[formatType].str
end