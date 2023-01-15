local CHTTP = x.RequireModule("chttp") and CHTTP or HTTP

x.STEAM_WEB_API_INTERFACE = x.STEAM_WEB_API_INTERFACE or {}
x.STEAM_WEB_API_INTERFACE.__index = x.STEAM_WEB_API_INTERFACE

function x.STEAM_WEB_API_INTERFACE:Request(interface, method, version, query, callback)
	x.ExpectString(interface)
	x.ExpectString(method)
	x.ExpectNumber(version)
	x.ExpectTableOrDefault(query, {})
	x.ExpectFunctionOrDefault(callback)

	query.key = self.Key

	CHTTP({
		url = string.format(
			"https://api.steampowered.com/%s/%s/v%04d",
			interface,
			method,
			version
		),

		parameters = query,

		success = function(code, body)
			local validationError
			local json = util.JSONToTable(body)

			if json and json.response then
				json = json.response
			else
				x.Warn(
					"[Steam Web API] Request %s/%s/%04d was success (%d), but no \"response\" key is available:\nBody: %s",
					interface,
					method,
					version,
					code,
					body
				)

				validationError = "No \"response\" key"
				json = nil
			end

			if callback then
				callback(validationError, json)
			end
		end,

		failed = function(err)
			x.Warn(
				"[Steam Web API] Request %s/%s/%04d failed: %s",
				interface,
				method,
				version,
				err
			)

			if callback then
				callback(err)
			end
		end
	})
end

function x.SteamWebApiInterface(key)
	key = x.ExpectStringOrDefault(key, x._SteamWebApiKey)
	x.Assert(key, "No steam web api key available!")

	return setmetatable({
		Key = key
	}, x.STEAM_WEB_API_INTERFACE)
end
