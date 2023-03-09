local prettiers = {
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

prettiers.Vehicle	= prettiers.Entity
prettiers.NPC		= prettiers.Entity
prettiers.NextBot	= prettiers.Entity

function x.PrettyPrintData(data)
	for i = 1, #data do
		local v = data[i]
		local prettier = prettiers[type(v)]

		if prettier then
			data[i] = prettier(v)
		else
			data[i] = v
		end
	end

	chat.AddText(unpack(data))
end

function x.PrettyPrint(...)
	x.PrettyPrintData({ ... })
end

net.Receive("xorlib_prettyprint", function()
	local data = x.NetReadVaargs()

	x.PrettyPrintData(data)
end)
