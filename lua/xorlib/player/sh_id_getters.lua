xorlib.Dependency("xorlib/hook", "sh_hooks.lua") -- HOOK_*

x.SteamIDPlayers	= x.SteamIDPlayers or {}
x.SteamID64Players	= x.SteamID64Players or {}
x.AccountIDPlayers	= x.AccountIDPlayers or {}

local steamIDPlayers	= x.SteamIDPlayers
local steamID64Players	= x.SteamID64Players
local accountIDPlayers	= x.AccountIDPlayers

function player.GetBySteamID(steamID)
	return steamIDPlayers[steamID]
end

function player.GetBySteamID64(steamID64)
	return steamID64Players[steamID64]
end

function player.GetByAccountID(accountID)
	return accountIDPlayers[accountID]
end

-- TODO: player.GetByID

local function addPlayer(ply)
	if ply:IsBot() then return end

	steamIDPlayers[ply:SteamID()] = true
	steamID64Players[ply:SteamID64()] = true
	accountIDPlayers[ply:AccountID()] = true
end

local function removePlayer(ply)
	if ply:IsBot() then return end

	steamIDPlayers[ply:SteamID()] = nil
	steamID64Players[ply:SteamID64()] = nil
	accountIDPlayers[ply:AccountID()] = nil
end

hook.Add("PlayerInitialSpawn", "xorlib_id_getters", x.Bind(timer.Simple, 0, addPlayer), HOOK_MONITOR_HIGH)
hook.Add("PlayerDisconnected", "xorlib_id_getters", removePlayer, HOOK_MONITOR_LOW)
