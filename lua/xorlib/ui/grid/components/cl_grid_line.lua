x.GRID_LINE = x.GRID_LINE or {}

local GRID_LINE = x.GRID_LINE
GRID_LINE.__index = GRID_LINE

function GRID_LINE:SetLength(length)
    self.Length = length

    self.GridParent:RecalculateGridLayout()

    return self
end

function GRID_LINE:SetMinLength(length)
    self.MinLength = length

    self.GridParent:RecalculateGridLayout()

    return self
end

function GRID_LINE:SetMaxLength(length)
    self.MaxLength = length

    self.GridParent:RecalculateGridLayout()

    return self
end

function x._GridLine(gridParentPanel, length)
    return setmetatable({
        GridParent       = gridParentPanel,

        Length           = length,
        MinLength        = nil,
        MaxLength        = nil,

        CalculatedLength = 0,
        CalculatedOffset = 0
    }, GRID_LINE)
end
