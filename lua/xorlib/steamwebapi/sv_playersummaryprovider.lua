xorlib.Dependency("xorlib/steamwebapi", "sv_webapi.lua")
if not x.SteamWebApiInterface then return end

x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER = x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER or {}
x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER.__index = x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER

local function parseSteamIDsArgument(steamids)
	for i, steamid in ipairs(steamids) do
		if type(steamid) == "Player" then
			steamid = steamid:SteamID64()
		end

		x.ExpectString(steamid)

		steamids[i] = steamid
	end
end

function x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER:Fetch(steamids, callback)
	x.ExpectTable(steamids)
	x.ExpectFunction(callback)

	parseSteamIDsArgument(steamids)

	self._Interface:Request(
		"ISteamUser",
		"GetPlayerSummaries",
		2,
		{ steamids = table.concat(steamids, ",") },
		function(err, players)
			if not err then
				players = players.players

				for i, info in ipairs(players) do
					self.Cached[info.steamid] = info
				end
			end

			if callback then
				callback(err, players)
			end
		end
	)
end

function x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER:TryGetCached(steamids, callback)
	x.ExpectTable(steamids)
	x.ExpectFunction(callback)

	local needToFetch = {}

	parseSteamIDsArgument(steamids)

	for i, steamid in ipairs(steamids) do
		if not self.Cached[steamid] then
			table.insert(needToFetch, steamid)
		end
	end

	local function collectInfoFromCache(dest)
		for i, steamid in ipairs(steamids) do
			table.insert(dest, self.Cached[steamid])
		end

		return dest
	end

	if #needToFetch ~= 0 then
		self:Fetch(needToFetch, function(err, players)
			if not callback then return end

			if not err then
				collectInfoFromCache(players)
			else
				players = nil
			end

			callback(err, players)
		end)
	else
		if callback then
			callback(nil, collectInfoFromCache({}))
		end
	end

	return #needToFetch
end

function x.SteamWebApiPlayerSummaryProvider(apiInterface)
	return setmetatable({
		Cached = {},
		_Interface = apiInterface
	}, x.STEAM_WEB_API_PLAYER_SUMMARY_PROVIDER)
end
