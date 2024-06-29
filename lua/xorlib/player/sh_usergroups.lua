xorlib.Dependency("xorlib/assert", "sh_assert.lua") -- x.Assert
xorlib.Dependency("xorlib/hook", "sh_utils.lua") -- hook.Once

x.PlayerGettersCache = x.PlayerGettersCache or {}

function x.RebuildPlayerGetters(funcName)
    local cache = x.Assert(x.PlayerGettersCache[funcName],
                           "Player getters \"%s\" is not registered!",
                           funcName)

    cache.Players:Clear()
    cache.Players:BulkEdit()

    for _, ply in player.Iterator() do
        if cache.Filter(ply) then
            cache.Players:Insert(ply)
        end
    end

    cache.Players:CommitBulkEdit()
end

function x.RegisterPlayerGetters(funcName, filter)
    local cache = x.PlayerGettersCache[funcName]

    if not cache then
        cache = {
            Filter  = filter,
            Players = x.Set()
        }

        x.PlayerGettersCache[funcName] = cache
    end

    hook.Add(SERVER and "PlayerInitialSpawn" or "CL_PlayerInitialSpawn", "xorlib_player_getter_" .. funcName, function(ply)
        if not filter(ply) then return end

        cache.Players:Insert(ply)
    end, HOOK_MONITOR_HIGH)

    hook.Add(SERVER and "PlayerDisconnected" or "CL_PlayerDisconnected", "xorlib_player_getter_" .. funcName, function(ply)
        cache.Players:Delete(ply)
    end, HOOK_MONITOR_LOW)

    if ULib then
        hook.Add(ULib.HOOK_UCLAUTH, "xorlib_player_getter_" .. funcName, function(ply)
            local plyIsInThisCache = cache.Players:Has(ply)

            if plyIsInThisCache == filter(ply) then
                -- group is not changed
                return
            end

            if plyIsInThisCache then
                -- player has been moved from this group
                cache.Players:Delete(ply)
            else
                -- player has been moved to this group
                cache.Players:Insert(ply)
            end
        end, HOOK_MONITOR_HIGH)
    elseif sam then
        -- TODO: support for sam
    end

    x["Get" .. funcName .. "Players"] = function()
        return cache.Players.Values
    end

    x.RebuildPlayerGetters(funcName)
end

local function registerPlayerGetters()
    local dontCreateDefaultGetters = hook.Run("XRegisterPlayerGetters")

    if dontCreateDefaultGetters ~= true then
        x.RegisterPlayerGetters("SuperAdmin", x.Meta("Player", "IsSuperAdmin"))
        x.RegisterPlayerGetters("Admin",      x.Meta("Player", "IsAdmin"))
    end
end

if sam then
    hook.Once("SAM.LoadedRanks", "xorlib_player_getters", registerPlayerGetters)
else
    x.EnsureInitPostEntity(registerPlayerGetters)
end
