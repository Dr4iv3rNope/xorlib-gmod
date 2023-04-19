--
-- Optimized version of CircleAvatar (AvatarMask) of Three's Derma Library
-- Three's Derma Library: https://github.com/Threebow/tdlib
--

xorlib.Dependency("xorlib/ui", "cl_masked_panel.lua")
xorlib.Dependency("xorlib/ui", "cl_poly.lua")

local MaskedPanel = baseclass.Get("MaskedPanel")

local PANEL = {}

function PANEL:Init()
	MaskedPanel.Init(self)

	self._Avatar = vgui.Create("AvatarImage", self)
end

function PANEL:BuildMask(w, h)
	return x.PolyCircle(w / 2, h / 2, 1, 32, w / 2, 0)
end

function PANEL:PerformLayout(w, h)
	self.Avatar:SetSize(w, h)
end

local function alias(funcName)
	PANEL[funcName] = function(self, ...)
		local avatarFunc = self.Avatar[funcName]

		return avatarFunc(self.Avatar, ...)
	end
end

alias("SetPlayer")
alias("SetSteamID")

vgui.Register("CircleAvatarImage", PANEL, "MaskedPanel")
