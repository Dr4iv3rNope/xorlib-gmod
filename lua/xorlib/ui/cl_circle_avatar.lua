--
-- Optimized version of CircleAvatar (AvatarMask) of Three's Derma Library
-- Three's Derma Library: https://github.com/Threebow/tdlib
--

xorlib.Dependency("xorlib/functional", "sh_getters.lua") -- x.Meta

local STENCILOPERATION_REPLACE			= STENCILOPERATION_REPLACE
local STENCILOPERATION_ZERO				= STENCILOPERATION_ZERO
local STENCILCOMPARISONFUNCTION_NEVER	= STENCILCOMPARISONFUNCTION_NEVER
local STENCILCOMPARISONFUNCTION_EQUAL	= STENCILCOMPARISONFUNCTION_EQUAL
local draw_NoTexture					= draw.NoTexture
local surface_SetDrawColor				= surface.SetDrawColor
local surface_DrawPoly					= surface.DrawPoly
local render_ClearStencil				= render.ClearStencil
local render_SetStencilEnable			= render.SetStencilEnable
local render_SetStencilWriteMask		= render.SetStencilWriteMask
local render_SetStencilTestMask			= render.SetStencilTestMask
local render_SetStencilFailOperation	= render.SetStencilFailOperation
local render_SetStencilPassOperation	= render.SetStencilPassOperation
local render_SetStencilZFailOperation	= render.SetStencilZFailOperation
local render_SetStencilCompareFunction	= render.SetStencilCompareFunction
local render_SetStencilReferenceValue	= render.SetStencilReferenceValue
local Panel_SetPaintManually			= x.Meta("Panel", "SetPaintedManually")
local Panel_PaintManual					= x.Meta("Panel", "PaintManual")

local PANEL = {}

local function alias(funcName)
	PANEL[funcName] = function(self, ...)
		local avatarFunc = self.Avatar[funcName]

		return avatarFunc(self.Avatar, ...)
	end
end

function PANEL:Init()
	self.Avatar = vgui.Create("AvatarImage", self)
	self.CircleMask = {}
end

function PANEL:PerformLayout(w, h)
	self.CircleMask = x.PolyCircle(w / 2, h / 2, 1, 32, w / 2, 0)

	self.Avatar:SetSize(w, h)
end

function PANEL:Paint(w, h)
	-- https://github.com/Threebow/tdlib/blob/ee8f562ab5d1f2540491ded39990843da0d9fb00/tdlib.lua#L415-L444
	render_ClearStencil()
	render_SetStencilEnable(true)

	render_SetStencilWriteMask(1)
	render_SetStencilTestMask(1)

	render_SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render_SetStencilPassOperation(STENCILOPERATION_ZERO)
	render_SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render_SetStencilReferenceValue(1)

	draw_NoTexture()
	surface_SetDrawColor(255, 255, 255)
	surface_DrawPoly(self.CircleMask)

	render_SetStencilFailOperation(STENCILOPERATION_ZERO)
	render_SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render_SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render_SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render_SetStencilReferenceValue(1)

	local avatar = self.Avatar

	Panel_SetPaintManually(avatar, false)
	Panel_PaintManual(avatar)
	Panel_SetPaintManually(avatar, true)

	render_SetStencilEnable(false)
	render_ClearStencil()
end

alias("SetPlayer")
alias("SetSteamID")

vgui.Register("CircleAvatarImage", PANEL, "Panel")
