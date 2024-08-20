xorlib.Dependency("xorlib/table", "sh_map.lua") -- x.MapSequence

x.DataPrettiers = {
    ["nil"] = function()
        return "nil"
    end,

    number = function(x)
        return tostring(x)
    end,

    boolean = function(x)
        return x and "true" or "false"
    end,

    Player = function(ply)
        if not IsValid(ply) then return "[NULL]" end

        return string.format("%s [%s]", ply:Nick(), ply:SteamID())
    end,

    Entity = function(ent)
        if not IsValid(ent) then return "(NULL)" end

        return string.format("%s (#%d %s)", ent:GetClass(), ent:EntIndex(), ent:GetModel())
    end,

    Vector = function(vec)
        return string.format("[%.3f %.3f %.3f]", vec.x, vec.y, vec.z)
    end,

    Angle = function(ang)
        return string.format("(%.2f %.2f %.2f)", ang.p, ang.y, ang.r)
    end
}

x.DataPrettiers.Weapon  = x.DataPrettiers.Entity
x.DataPrettiers.Vehicle = x.DataPrettiers.Entity
x.DataPrettiers.NPC     = x.DataPrettiers.Entity
x.DataPrettiers.NextBot = x.DataPrettiers.Entity

function x.PrettyValue(v)
    local prettier = x.DataPrettiers[type(v)]

    return prettier and prettier(v) or v
end

function x.PrettySequence(tbl)
    return x.MapSequence(tbl, x.PrettyValue)
end

local function internalPrettyVaargs(value, ...)
    if value == nil then return end

    return x.PrettyValue(value), internalPrettyVaargs(...)
end

function x.PrettyVaargs(...)
    return internalPrettyVaargs(...)
end
