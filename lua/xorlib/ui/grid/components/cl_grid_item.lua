x.GRID_ITEM = x.GRID_ITEM or {}

local GRID_ITEM = x.GRID_ITEM
GRID_ITEM.__index = GRID_ITEM

function GRID_ITEM:GetAbsColumnStart()
    return self.GridParent:GetAbsColumnNumber(self.ColumnStart)
end

function GRID_ITEM:GetAbsColumnEnd()
    return self.GridParent:GetAbsColumnNumber(self.ColumnEnd)
end

function GRID_ITEM:GetAbsRowStart()
    return self.GridParent:GetAbsRowNumber(self.RowStart)
end

function GRID_ITEM:GetAbsRowEnd()
    return self.GridParent:GetAbsRowNumber(self.RowEnd)
end

function GRID_ITEM:GetPos()
    return self.CalculatedX, self.CalculatedY
end

function GRID_ITEM:GetSize()
    return self.CalculatedWidth, self.CalculatedTall
end

function GRID_ITEM:GetRect()
    return self.CalculatedX,     self.CalculatedY,
           self.CalculatedWidth, self.CalculatedTall
end

function GRID_ITEM:SetPadding(left, top, right, bottom)
    if top == nil then
        return self:SetPadding(left, left, left, left)
    end

    self.PaddingLeft   = left
    self.PaddingTop    = top
    self.PaddingRight  = right
    self.PaddingBottom = bottom

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetLeftPadding(px)
    self.PaddingLeft = px

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetTopPadding(px)
    self.PaddingTop = px

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetRightPadding(px)
    self.PaddingRight = px

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetBottomPadding(px)
    self.PaddingBottom = px

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetPercentX(px)
    self.PercentX = px

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetPercentY(py)
    self.PercentY = py

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetPercentPos(px, py)
    self.PercentX = px
    self.PercentY = py

    self:CalculateLayout()

    return self
end

function GRID_ITEM:Left()
    return self:SetPercentX(0)
end

function GRID_ITEM:Right()
    return self:SetPercentX(1)
end

function GRID_ITEM:Top()
    return self:SetPercentY(0)
end

function GRID_ITEM:Bottom()
    return self:SetPercentY(1)
end

function GRID_ITEM:Center()
    return self:SetPercentPos(0.5, 0.5)
end

function GRID_ITEM:CenterX()
    return self:SetPercentX(0.5)
end

function GRID_ITEM:CenterY()
    return self:SetPercentY(0.5)
end

function GRID_ITEM:SetPercentSize(pw, ph)
    self.PercentWidth = pw
    self.PercentTall  = ph

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetScale(scale)
    return self:SetPercentSize(scale, scale)
end

function GRID_ITEM:SetFixedSize(w, h)
    self.FixedWidth = w
    self.FixedTall  = h

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetMinSize(w, h)
    self.MinWidth = w
    self.MinTall  = h

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetMaxSize(w, h)
    self.MaxWidth = w
    self.MaxTall  = h

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetFixedWidth(width)
    self.FixedWidth = width

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetFixedTall(tall)
    self.FixedTall = tall

    self:CalculateLayout()

    return self
end

function GRID_ITEM:KeepAspect(aspectW, aspectH)
    self.Aspect = {
        Width           = aspectW,
        Tall            = aspectH,

        CalculatedWidth = 0,
        CalculatedTall  = 0
    }

    return self
end

function GRID_ITEM:SetMinWidth(width)
    self.MinWidth = width

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetMinTall(tall)
    self.MinTall = tall

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetMaxWidth(width)
    self.MaxWidth = width

    self:CalculateLayout()

    return self
end

function GRID_ITEM:SetMaxTall(tall)
    self.MaxTall = tall

    self:CalculateLayout()

    return self
end

function GRID_ITEM:CalculateLayout()
    local rx, ry, rw, rh = self.GridParent:CalculateRect(
        self.ColumnStart, self.ColumnEnd,
        self.RowStart, self.RowEnd
    )

    local x, y, w, h

    x = rx + self.PaddingLeft
    y = ry + self.PaddingTop

    if not self.Aspect then
        if self.FixedWidth then
            w = self.FixedWidth
        else
            w = rw - self.PaddingLeft - self.PaddingRight
        end

        if self.FixedTall then
            h = self.FixedTall
        else
            h = rh - self.PaddingTop - self.PaddingBottom
        end

        -- Limit size
        if self.MinWidth then
            w = math.max(w, self.MinWidth)
        end

        if self.MaxWidth then
            w = math.min(w, self.MaxWidth)
        end

        if self.MinTall then
            h = math.max(h, self.MinTall)
        end

        if self.MaxTall then
            h = math.min(h, self.MaxTall)
        end
    else
        local _, _, aw, ah = x.AlignRect(
            rw, rh,
            self.Aspect.Width, self.Aspect.Tall,
            x.ALIGN_RECT_FIT
        )

        w = aw
        h = ah
    end

    -- Calculating size percent
    w = w * self.PercentWidth
    h = h * self.PercentTall

    -- Calculating position percent
    x = x + ((rw - w) * self.PercentX)
    y = y + ((rh - h) * self.PercentY)

    self.CalculatedX     = x
    self.CalculatedY     = y
    self.CalculatedWidth = w
    self.CalculatedTall  = h

    if IsValid(self.Panel) then
        self.Panel:SetPos(x, y)
        self.Panel:SetSize(w, h)
    end
end

function GRID_ITEM:Remove()
    self.GridParent:RemoveItem(self)
end

function x._GridItem(
    gridParentPanel,
    panel,
    columnStart, columnEnd,
    rowStart, rowEnd
)
    return setmetatable({
        GridParent      = gridParentPanel,
        Panel           = panel,

        ColumnStart     = columnStart,
        ColumnEnd       = columnEnd,
        RowStart        = rowStart,
        RowEnd          = rowEnd,

        FixedWidth      = nil,
        FixedTall       = nil,

        MinWidth        = nil,
        MaxWidth        = nil,
        MinTall         = nil,
        MaxTall         = nil,

        PercentX        = 0,
        PercentY        = 0,
        PercentWidth    = 1,
        PercentTall     = 1,

        PaddingLeft     = 0,
        PaddingTop      = 0,
        PaddingRight    = 0,
        PaddingBottom   = 0,

        CalculatedX     = 0,
        CalculatedY     = 0,
        CalculatedWidth = 0,
        CalculatedTall  = 0,
    }, GRID_ITEM)
end
