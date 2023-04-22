xorlib.Dependency("xorlib/ui", "cl_mask.lua")

local StartDrawMasked	= x.StartDrawMasked
local EndDrawMasked		= x.EndDrawMasked

local PANEL = {}

function PANEL:Init()
	self._CachedMask = {}
end

function PANEL:PerformLayout(w, h)
	self._CachedMask = self:BuildMask(w, h)
end

function PANEL:Paint(w, h)
	StartDrawMasked(self._CachedMask)

	for _, child in ipairs(self:GetChildren()) do
		child:SetPaintedManually(true)
		child:PaintManual()
		child:SetPaintedManually(false)
	end

	self:PaintMasked(w, h)

	EndDrawMasked()
end

function PANEL:BuildMask(w, h)
	-- for override

	return {}
end

function PANEL:PaintMasked(w, h)
	-- for override
end

vgui.Register("MaskedPanel", PANEL, "Panel")
