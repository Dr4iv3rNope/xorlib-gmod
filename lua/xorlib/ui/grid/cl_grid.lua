local PANEL = {}

local gridDebug = CreateClientConVar("xgrid_debug", "0", false)

local GRID_DEBUG_ALL     = 1
local GRID_DEBUG_HOVERED = 2
local GRID_DEBUG_ITEM    = 3

local function calculateFreeAndAvailableLinesLength(lines,
                                                    totalLength,
                                                    spacing,
                                                    paddingStart,
                                                    paddingEnd)
    local freeLength = totalLength - paddingStart - paddingEnd
    local availableLength

    -- subtract free space by elements with fixed length
    for _, element in ipairs(lines) do
        if element.Length > 1 then
            freeLength = freeLength - element.Length

            element.CalculatedLength = element.Length
        end
    end

    availableLength = freeLength

    -- subtract spacing
    availableLength = availableLength - (spacing * (#lines - 1))

    -- calculate width for elements with percentage length
    for _, element in ipairs(lines) do
        if element.Length > 0 and element.Length <= 1 then
            local totalElementLength = freeLength * element.Length

            local clampMinLength = element.MinLength and
                                   totalElementLength < element.MinLength

            local clampMaxLength = element.MaxLength and
                                   totalElementLength > element.MaxLength

            if clampMinLength then
                totalElementLength = element.MinLength
            elseif clampMaxLength then
                totalElementLength = element.MaxLength
            end

            element.CalculatedLength = totalElementLength
            availableLength = availableLength - totalElementLength
        end
    end

    local fillElements = {}

    -- calulate fill elements count
    for _, element in ipairs(lines) do
        if element.Length == 0 then
            table.insert(fillElements, element)
        end
    end

    -- calculate length of filling elements
    if #fillElements ~= 0 then
        local function calculateFillElementLength()
            return availableLength / #fillElements
        end

        -- clamp size
        x.FilterSequence(fillElements, function(e)
            local fillElementLength = calculateFillElementLength()
            local clampedLength

            if e.MaxLength and fillElementLength > e.MaxLength then
                clampedLength = e.MaxLength
            elseif e.MinLength and fillElementLength < e.MinLength then
                clampedLength = e.MinLength
            end

            if clampedLength then
                e.CalculatedLength = clampedLength
                availableLength = availableLength - clampedLength

                return false
            else
                return true
            end
        end)

        -- set length of fill elements
        do
            local fillElementLength = calculateFillElementLength()

            for _, element in ipairs(fillElements) do
                element.CalculatedLength = fillElementLength
            end
        end
    end
end

local function calculateLinesOffsets(lines, spacing, paddingStart)
    local offset = paddingStart

    for _, element in ipairs(lines) do

        element.CalculatedOffset = offset
        offset = offset + element.CalculatedLength

        -- add spacing
        offset = offset + spacing
    end
end

function PANEL:RecalculateItemsLayout()
    for _, item in ipairs(self.Items.Values) do
        item:CalculateLayout()
    end
end

function PANEL:RecalculateFreeAndAvailableColumnsWidth(dontCalculateLayout)
    calculateFreeAndAvailableLinesLength(self.Columns,
                                         self:GetWide(),
                                         self.Spacing,
                                         self.PaddingLeft,
                                         self.PaddingRight)

    calculateLinesOffsets(self.Columns, self.Spacing, self.PaddingLeft)

    if not dontCalculateLayout then
        self:RecalculateItemsLayout()
    end
end

function PANEL:RecalculateFreeAndAvailableRowsTall(dontCalculateLayout)
    calculateFreeAndAvailableLinesLength(self.Rows,
                                         self:GetTall(),
                                         self.Spacing,
                                         self.PaddingTop,
                                         self.PaddingBottom)

    calculateLinesOffsets(self.Rows, self.Spacing, self.PaddingTop)

    if not dontCalculateLayout then
        self:RecalculateItemsLayout()
    end
end

function PANEL:RecalculateGridLayout(force)
    if not force then
        self._RecalculateGridLayout = true
        self:InvalidateLayout()

        return
    end

    self._RecalculateGridLayout = nil

    self:RecalculateFreeAndAvailableColumnsWidth()
    self:RecalculateFreeAndAvailableRowsTall()

    self:RecalculateItemsLayout()
end

function PANEL:GetAbsColumnNumber(num)
    if num < 0 then
        return #self.Columns - ((-num) - 1)
    elseif num >= 1 then
        return num
    else
        x.Error("Column number cannot be zero!")
    end
end

function PANEL:GetAbsRowNumber(num)
    if num < 0 then
        return #self.Rows - ((-num) - 1)
    elseif num >= 1 then
        return num
    else
        x.Error("Row number cannot be zero!")
    end
end

function PANEL:GetColumn(num)
    return self.Columns[self:GetAbsColumnNumber(num)]
end

function PANEL:GetRow(num)
    return self.Rows[self:GetAbsRowNumber(num)]
end

function PANEL:CalculateOffset(columnStart, rowStart)
    local x = self:GetColumn(columnStart).CalculatedOffset
    local y = self:GetRow(rowStart).CalculatedOffset

    return x, y
end

function PANEL:CalculateSize(columnStart, columnEnd, rowStart, rowEnd)
    columnStart = self:GetAbsColumnNumber(columnStart)
    columnEnd   = self:GetAbsColumnNumber(columnEnd)
    rowStart    = self:GetAbsRowNumber(rowStart)
    rowEnd      = self:GetAbsRowNumber(rowEnd)

    local w = 0
    local h = 0

    for columnNum = columnStart, columnEnd do
        local column = self.Columns[columnNum]

        w = w + column.CalculatedLength
    end

    for rowNum = rowStart, rowEnd do
        local row = self.Rows[rowNum]

        h = h + row.CalculatedLength
    end

    -- ignore spacing
    do
        local columnSpacers = math.max(0, columnEnd - columnStart)
        local rowSpacers    = math.max(0, rowEnd    - rowStart)

        w = w + (columnSpacers * self.Spacing)
        h = h + (rowSpacers    * self.Spacing)
    end

    return w, h
end

function PANEL:CalculateRect(columnStart, columnEnd, rowStart, rowEnd)
    local x, y = self:CalculateOffset(columnStart, rowStart)
    local w, h = self:CalculateSize(columnStart, columnEnd, rowStart, rowEnd)

    return x, y, w, h
end

function PANEL:_AddLine(lines,
                        length,
                        after,
                        overlap,
                        startModifyKeyName,
                        endModifyKeyName,
                        findColumnStart, findColumnEnd,
                        findRowStart, findRowEnd)
    local line = x._GridLine(self, length)

    local intersecting = self:FindIntersecting(findColumnStart, findColumnEnd,
                                               findRowStart, findRowEnd)

    for _, item in ipairs(intersecting) do
        local startNum = item[startModifyKeyName]
        local endNum = item[endModifyKeyName]

        if startNum == after then
            if not overlap then
                item[startModifyKeyName] = x.AddGridNumber(
                    startNum,
                    1
                )
            end
        else
            item[endModifyKeyName] = x.AddGridNumber(endNum, 1)
        end
    end

    table.insert(lines, after, line)

    self:RecalculateGridLayout()

    return line
end

function PANEL:AddColumn(width, columnAfter, overlap)
    columnAfter = columnAfter or (#self.Columns + 1)
    columnAfter = self:GetAbsColumnNumber(columnAfter)

    return self:_AddLine(
        self.Columns,
        width,
        columnAfter,
        overlap,
        "ColumnStart",
        "ColumnEnd",
        columnAfter, columnAfter,
        1, -1
    )
end

function PANEL:AddRow(tall, rowAfter, overlap)
    rowAfter = rowAfter or (#self.Rows + 1)
    rowAfter = self:GetAbsRowNumber(rowAfter)

    return self:_AddLine(
        self.Rows,
        tall,
        rowAfter,
        overlap,
        "RowStart",
        "RowEnd",
        1, -1,
        rowAfter, rowAfter
    )
end

function PANEL:AddColumns(width, ...)
    if not width then return end

    self:AddColumn(width)

    return self:AddColumns(...)
end

function PANEL:AddRows(tall, ...)
    if not tall then return end

    self:AddRow(tall)

    return self:AddRows(...)
end

-- https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
function PANEL:_CheckIntersect(item, columnStart, columnEnd, rowStart, rowEnd)
    columnStart = self:GetAbsColumnNumber(columnStart)
    columnEnd = self:GetAbsColumnNumber(columnEnd)
    rowStart = self:GetAbsRowNumber(rowStart)
    rowEnd = self:GetAbsRowNumber(rowEnd)

    return item:GetAbsColumnStart() <= columnEnd and
           item:GetAbsColumnEnd()   >= columnStart and
           item:GetAbsRowStart()    <= rowEnd and
           item:GetAbsRowEnd()      >= rowStart
end

function PANEL:CheckIntersect(columnStart, columnEnd, rowStart, rowEnd)
    for _, item in ipairs(self.Items.Values) do
        if self:_CheckIntersect(item,
                                columnStart,
                                columnEnd,
                                rowStart,
                                rowEnd)
        then
            return true
        end
    end

    return false
end

function PANEL:FindItemByPanel(panel)
    for i, item in ipairs(self.Items.Values) do
        if item.Panel == panel then
            return item, i
        end
    end

    return nil, nil
end

function PANEL:FindIntersecting(columnStart, columnEnd, rowStart, rowEnd)
    local intersecting = {}

    for _, item in ipairs(self.Items.Values) do
        if self:_CheckIntersect(item,
                                columnStart,
                                columnEnd,
                                rowStart,
                                rowEnd)
        then
            table.insert(intersecting, item)
        end
    end

    return intersecting
end

function PANEL:InsertItem(panel,
                          columnStart, columnEnd,
                          rowStart, rowEnd,
                          rememberLines)
    if rememberLines then
        columnStart = self:GetAbsColumnNumber(columnStart)
        columnEnd   = self:GetAbsColumnNumber(columnEnd)
        rowStart    = self:GetAbsRowNumber(rowStart)
        rowEnd      = self:GetAbsRowNumber(rowEnd)
    end

    x.Assert(self:GetColumn(columnStart),
             "Column start (%d) doesn't exist!",
             columnStart)

    x.Assert(self:GetColumn(columnEnd),
             "Column end (%d) doesn't exist!",
             columnEnd)

    x.Assert(self:GetRow(rowStart),
             "Row start (%d) doesn't exist!",
             rowStart)

    x.Assert(self:GetRow(rowEnd),
             "Row end (%d) doesn't exist!",
             rowEnd)

    local item = x._GridItem(self,
                             panel,
                             columnStart,
                             columnEnd,
                             rowStart,
                             rowEnd)
    item:CalculateLayout()

    if IsValid(panel) then
        panel:SetParent(self)
    end

    self.Items:Insert(item)

    return item
end

function PANEL:CreateItem(panelClass,
                          columnStart, columnEnd,
                          rowStart, rowEnd,
                          rememberLines)
    local panel = self:CreateStyledChild(panelClass)

    local item  = self:InsertItem(panel,
                                  columnStart, columnEnd,
                                  rowStart, rowEnd,
                                  rememberLines)

    return panel, item
end

function PANEL:RemoveItem(item)
    self.Items:Delete(item)

    if IsValid(item.Panel) then
        item.Panel:Remove()
    end
end

function PANEL:SetSpacing(spacing)
    self.Spacing = spacing

    self:RecalculateGridLayout()

    return self
end

function PANEL:SetPadding(left, top, right, bottom)
    if top == nil then
        return self:SetPadding(left, left, left, left)
    end

    self.PaddingLeft   = left
    self.PaddingTop    = top
    self.PaddingRight  = right
    self.PaddingBottom = bottom

    self:RecalculateGridLayout()

    return self
end

function PANEL:ClearItems()
    self.Items:Clear()
    self:Clear()
end

function PANEL:ResetColumns()
    x.EmptySequence(self.Columns)
end

function PANEL:ResetRows()
    x.EmptySequence(self.Rows)
end

function PANEL:Reset()
    self:ResetColumns()
    self:ResetRows()
end

function PANEL:PaintDebug()
    local i = 0
    local maxI = #self.Rows * #self.Columns
    local stepI = 360 / maxI

    for rowNum, row in ipairs(self.Rows) do
        for columnNum, column in ipairs(self.Columns) do
            local render = true

            surface.SetAlphaMultiplier(0.1)

            if gridDebug:GetInt() == GRID_DEBUG_ITEM then
                render = false
            end

            local intersecting = self:FindIntersecting(columnNum, columnNum,
                                                       rowNum, rowNum)

            for _, item in ipairs(intersecting) do
                if
                    gridDebug:GetInt() < GRID_DEBUG_ITEM or
                    (
                        IsValid(item.Panel) and
                        item.Panel:IsHovered()
                    )
                then
                    render = true

                    surface.SetDrawColor(255, 255, 255)

                    surface.DrawOutlinedRect(
                        item.CalculatedX,
                        item.CalculatedY,
                        item.CalculatedWidth,
                        item.CalculatedTall
                    )

                    -- top line
                    surface.DrawLine(
                        column.CalculatedOffset + (column.CalculatedLength / 2),
                        row.CalculatedOffset,
                        item.CalculatedX + (item.CalculatedWidth / 2),
                        item.CalculatedY
                    )

                    -- right line
                    surface.DrawLine(
                        column.CalculatedOffset + column.CalculatedLength,
                        row.CalculatedOffset + (row.CalculatedLength / 2),
                        item.CalculatedX + item.CalculatedWidth,
                        item.CalculatedY + (item.CalculatedTall / 2)
                    )

                    -- bottom line
                    surface.DrawLine(
                        column.CalculatedOffset + (column.CalculatedLength / 2),
                        row.CalculatedOffset + row.CalculatedLength,
                        item.CalculatedX + (item.CalculatedWidth / 2),
                        item.CalculatedY + item.CalculatedTall
                    )

                    -- left line
                    surface.DrawLine(
                        column.CalculatedOffset,
                        row.CalculatedOffset + (row.CalculatedLength / 2),
                        item.CalculatedX,
                        item.CalculatedY + (item.CalculatedTall / 2)
                    )
                end
            end

            surface.SetDrawColor(HSVToColor(i, 1, 1))

            if render then
                surface.DrawRect(
                    column.CalculatedOffset,
                    row.CalculatedOffset,
                    column.CalculatedLength,
                    row.CalculatedLength
                )

                surface.DrawOutlinedRect(
                    column.CalculatedOffset,
                    row.CalculatedOffset,
                    column.CalculatedLength,
                    row.CalculatedLength
                )

                draw.SimpleTextOutlined(
                    string.format(
                        "%dx%d",
                        column.CalculatedLength,
                        row.CalculatedLength
                    ),
                    "Default",
                    column.CalculatedOffset + (column.CalculatedLength / 2),
                    row.CalculatedOffset + (row.CalculatedLength / 2),
                    x.ColorWhite,
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER,
                    1,
                    x.ColorBlack
                )
            end

            surface.SetAlphaMultiplier(1)

            i = (i + stepI) % 360
        end
    end
end

function PANEL:EnableDebugPaint()
    local oPaintOver = self.PaintOver

    local function newPaintOver(self)
        if
            gridDebug:GetInt() == GRID_DEBUG_HOVERED and
            not self:IsHovered() and
            not self:IsChildHovered()
        then
            return
        end

        self:PaintDebug()
    end

    if oPaintOver then
        function self:PaintOver(w, h)
            oPaintOver(self, w, h)
            newPaintOver(self)
        end
    else
        self.PaintOver = newPaintOver
    end
end

function PANEL:PerformLayout(w, h)
    self:RecalculateGridLayout(true)
end

function PANEL:Think()
    if self._RecalculateGridLayout then
        self:RecalculateGridLayout(true)
    end
end

function PANEL:Init()
    self.Items   = x.Set()
    self.Columns = {}
    self.Rows    = {}

    self.Spacing = 0

    self.PaddingLeft   = 0
    self.PaddingTop    = 0
    self.PaddingRight  = 0
    self.PaddingBottom = 0

    if gridDebug:GetBool() then
        timer.Simple(0, function()
            self:EnableDebugPaint()
        end)
    end
end

vgui.Register("XGrid", PANEL, "EditablePanel")
