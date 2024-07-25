x.ALIGN_RECT_FIT  = 0
x.ALIGN_RECT_CROP = 1

function x.AlignRect(canvasWidth, canvasHeight,
                     w, h,
                     alignType,
                     alignX, alignY)
    alignX = alignX or 0.5
    alignY = alignY or 0.5

    local newX, newY = 0, 0
    local newW, newH = 0, 0

    local panelAspectRatio = canvasHeight / canvasWidth
    local materialAspectRatio = h / w

    local function keepVertical()
        local ratio = w / h

        newW = canvasHeight * ratio
        newH = canvasHeight
        newX = (canvasWidth - newW) * alignX
        newY = 0
    end

    local function keepHorizontal()
        local ratio = materialAspectRatio

        newW = canvasWidth
        newH = canvasWidth * ratio
        newX = 0
        newY = (canvasHeight - newH) * alignY
    end

    if panelAspectRatio > materialAspectRatio then
        if alignType == x.ALIGN_RECT_FIT then
            keepHorizontal()
        elseif alignType == x.ALIGN_RECT_CROP then
            keepVertical()
        end
    elseif panelAspectRatio < materialAspectRatio then
        if alignType == x.ALIGN_RECT_FIT then
            keepVertical()
        elseif alignType == x.ALIGN_RECT_CROP then
            keepHorizontal()
        end
    else
        newW = canvasWidth
        newH = canvasHeight
    end

    return newX, newY, newW, newH
end
