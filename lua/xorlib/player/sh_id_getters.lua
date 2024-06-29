xorlib.Dependency("xorlib/hook", "sh_hooks.lua") -- HOOK_*
xorlib.Dependency("xorlib/table", "sh_enumeration.lua") -- x.EachSequence

x._Old_player_GetBySteamID   = x._Old_player_GetBySteamID   or player.GetBySteamID
x._Old_player_GetBySteamID64 = x._Old_player_GetBySteamID64 or player.GetBySteamID64
x._Old_player_GetByAccountID = x._Old_player_GetByAccountID or player.GetByAccountID

--[[
    x.PlayerIDCache[userid] = {
        SteamID = string,
        SteamID64 = string,
        AccountID = number,
    }
]]
x.PlayerIDCache = x.PlayerIDCache or {}

x.SteamIDPlayers             = x.SteamIDPlayers or {}
x.SteamID64Players           = x.SteamID64Players or {}
x.AccountIDPlayers           = x.AccountIDPlayers or {}

local playerIdCache          = x.PlayerIDCache
local steamIDPlayers         = x.SteamIDPlayers
local steamID64Players       = x.SteamID64Players
local accountIDPlayers       = x.AccountIDPlayers

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

    playerIdCache[ply:UserID()] = {
        SteamID   = ply:SteamID(),
        SteamID64 = ply:SteamID64(),
        AccountID = ply:AccountID()
    }

    steamIDPlayers[ply:SteamID()]     = ply
    steamID64Players[ply:SteamID64()] = ply
    accountIDPlayers[ply:AccountID()] = ply
end

local function removePlayerByUserID(userId)
    local idCache = x.PlayerIDCache[userId]

    x.PlayerIDCache[userId] = nil

    steamIDPlayers[idCache.SteamID]     = nil
    steamID64Players[idCache.SteamID64] = nil
    accountIDPlayers[idCache.AccountID] = nil
end

hook.Add(SERVER and "PlayerInitialSpawn" or "CL_PlayerInitialSpawn", "xorlib_id_getters", addPlayer, HOOK_MONITOR_HIGH)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "xorlib_id_getters", function(data)
    if data.bot == 1 then return end

    removePlayerByUserID(data.userid)
end, HOOK_MONITOR_LOW)

x.EnsureInitPostEntity(function()
    x.EachSequence(player.GetAll(), addPlayer)
end)
