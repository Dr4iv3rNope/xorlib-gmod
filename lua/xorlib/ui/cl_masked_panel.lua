xorlib.Dependency("xorlib/ui", "cl_mask.lua")

local StartDrawMasked = x.StartDrawMasked
local EndDrawMasked   = x.EndDrawMasked

local PANEL = {}

function PANEL:BuildMask(w, h)
    -- for override

    return {}
end

function PANEL:PaintMasked(w, h)
    -- for override
end

function PANEL:PaintOverMasked(w, h)
    -- for override
end

function PANEL:PerformLayout(w, h)
    self._CachedMask = self:BuildMask(w, h)
end

function PANEL:Paint(w, h)
    StartDrawMasked(self._CachedMask)

    self:PaintMasked(w, h)

    for _, child in ipairs(self:GetChildren()) do
        child:PaintManual()
    end

    self:PaintOverMasked(w, h)

    EndDrawMasked()
end

function PANEL:OnChildAdded(child)
    child:SetPaintedManually(true)
end

function PANEL:Init()
    self._CachedMask = {}
end

vgui.Register("MaskedPanel", PANEL, "Panel")
