xorlib.Dependency("xorlib/ui", "cl_screen.lua") -- x.SetupScreenSize

local BLUR_MATERIAL = Material("pp/blurscreen")

x.SetupScreenSize(function(w, h)
    function x.DrawBlur(panel, power, passes)
        power  = power  or 3
        passes = passes or 3

        local x, y = panel:LocalToScreen(0, 0)

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(BLUR_MATERIAL)

        for i = 1, passes do
            BLUR_MATERIAL:SetFloat("$blur", (i / passes) * power)
            BLUR_MATERIAL:Recompute()

            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(-x, -y, w, h)
        end
    end
end)
