xorlib.Dependency("xorlib/hook", "sh_hooks.lua") -- HOOK_*
xorlib.Dependency("xorlib/table", "sh_enumeration.lua") -- x.EachSequence

x._Old_player_GetBySteamID		= x._Old_player_GetBySteamID or player.GetBySteamID
x._Old_player_GetBySteamID64	= x._Old_player_GetBySteamID64 or player.GetBySteamID64
x._Old_player_GetByAccountID	= x._Old_player_GetByAccountID or player.GetByAccountID

x.SteamIDPlayers	= x.SteamIDPlayers or {}
x.SteamID64Players	= x.SteamID64Players or {}
x.AccountIDPlayers	= x.AccountIDPlayers or {}

local steamIDPlayers	= x.SteamIDPlayers
local steamID64Players	= x.SteamID64Players
local accountIDPlayers	= x.AccountIDPlayers

function player.GetBySteamID(steamID)
	return steamIDPlayers[steamID] or x._Old_player_GetBySteamID(steamID)
end

function player.GetBySteamID64(steamID64)
	return steamID64Players[steamID64] or x._Old_player_GetBySteamID64(steamID64)
end

function player.GetByAccountID(accountID)
	return accountIDPlayers[accountID] or x._Old_player_GetByAccountID(accountID)
end

-- TODO: player.GetByID

local function addPlayer(ply)
	if ply:IsBot() then return end

	steamIDPlayers[ply:SteamID()] = ply
	steamID64Players[ply:SteamID64()] = ply
	accountIDPlayers[ply:AccountID()] = ply
end

local function removePlayer(ply)
	if ply:IsBot() then return end

	steamIDPlayers[ply:SteamID()] = nil
	steamID64Players[ply:SteamID64()] = nil
	accountIDPlayers[ply:AccountID()] = nil
end

hook.Add("PlayerInitialSpawn", "xorlib_id_getters", addPlayer, HOOK_MONITOR_HIGH)
hook.Add("PlayerDisconnected", "xorlib_id_getters", removePlayer, HOOK_MONITOR_LOW)

x.EnsureInitPostEntity(function()
	x.EachSequence(player.GetAll(), addPlayer)
end)
