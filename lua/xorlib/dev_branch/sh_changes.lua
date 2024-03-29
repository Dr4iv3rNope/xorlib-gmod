xorlib.Dependency("xorlib/dev_branch", "sh_base.lua")

local PLAYER = FindMetaTable("Player")

if not xorlib.CheckDevBranchFunction(nil, "net.ReadPlayer") then
    net.ReadPlayer = net.ReadEntity
end

if not xorlib.CheckDevBranchFunction(nil, "net.WritePlayer") then
    net.WritePlayer = net.WriteEntity
end

if not xorlib.CheckDevBranchFunction(nil, "ents.Iterator") then
    function ents.Iterator()
        return ipairs(ents.GetAll())
    end
end

if not xorlib.CheckDevBranchFunction(nil, "player.Iterator") then
    function player.Iterator()
        return ipairs(player.GetAll())
    end
end

if not xorlib.CheckDevBranchFunction(PLAYER, "IsWalking") then
    function PLAYER:IsWalking()
        return self:KeyDown(IN_WALK)
    end
end
