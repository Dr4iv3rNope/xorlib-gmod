local sin		= math.sin
local cos		= math.cos
local min		= math.min
local drawPoly	= surface.DrawPoly
local drawLine	= surface.DrawLine
local pi		= math.pi
local pi2		= pi * 2
local pi_2		= pi / 2

function x.PolyCircle(x, y, fillPercent, segments, radius, rotation)
	local polys			= {}
	local step			= (pi2 * fillPercent) / segments
	local indexOffset

	if fillPercent ~= 1 then
		indexOffset = 1

		polys[1] = {
			x = x,
			y = y
		}
	else
		indexOffset = 0
	end

	for i = 0, segments do
		local angle = i * step

		polys[i + 1 + indexOffset] = {
			x = x + (cos(angle + rotation) * radius),
			y = y + (sin(angle + rotation) * radius)
		}
	end

	return polys
end

-- !!! use ONLY with DrawTriangleStrip* functions !!!
function x.PolyArc(x, y, thickness, fillPercent, segments, radius, rotation)
	local polys			= {}
	local step			= (pi2 * fillPercent) / segments
	local innerRadius	= radius - thickness
	local tableSize		= (segments * 2) + 2

	local index			= 1
	local angleIndex	= 0

	while index <= tableSize do
		local angle = angleIndex * step

		local ax = cos(angle + rotation)
		local ay = sin(angle + rotation)

		polys[index] = {
			x = x + (ax * innerRadius),
			y = y + (ay * innerRadius)
		}

		polys[index + 1] = {
			x = x + (ax * radius),
			y = y + (ay * radius)
		}

		angleIndex = angleIndex + 1
		index = index + 2
	end

	return polys
end

function x.PolyRotate(polys, anchorX, anchorY, rotation)
	local sinAngle = sin(rotation)
	local cosAngle = cos(rotation)

	for i = 1, #polys do
		local coord = polys[i]
		local x = coord.x
		local y = coord.y

		-- https://stackoverflow.com/a/17411276

		coord.x = (cosAngle * (x - anchorX)) - (sinAngle * (y - anchorY)) + anchorX
		coord.y = (cosAngle * (y - anchorY)) + (sinAngle * (x - anchorX)) + anchorY
	end

	return polys
end

local function pushRoundedCorner(
	polys,
	x,
	y,
	inverseXOffset,
	inverseYOffset,
	segments,
	rotation,
	roundAmount
)
	local step = pi_2 / segments

	if inverseXOffset then
		x = x - roundAmount
	else
		x = x + roundAmount
	end

	if inverseYOffset then
		y = y - roundAmount
	else
		y = y + roundAmount
	end

	for i = 0, segments do
		local angle = i * step

		polys[#polys + 1] = {
			x = x + (cos(angle + rotation) * roundAmount),
			y = y + (sin(angle + rotation) * roundAmount)
		}
	end
end

function x.PolyRoundedBoxEx(
	x,
	y,
	w,
	h,
	segments,
	ltCornerRoundPercent,	-- Left Top
	rtCornerRoundPercent,	-- Right Top
	lbCornerRoundPercent,	-- Left Bottom
	rbCornerRoundPercent	-- Right Bottom
)
	local polys = {}

	local maxRoundAmount = min(w, h) / 2

	-- left top corner
	if ltCornerRoundPercent ~= 0 then
		pushRoundedCorner(
			polys,
			x,
			y,
			false,
			false,
			segments,
			pi,
			maxRoundAmount * ltCornerRoundPercent
		)
	else
		polys[1] = {
			x = x,
			y = y
		}
	end

	-- right top corner
	if rtCornerRoundPercent ~= 0 then
		pushRoundedCorner(
			polys,
			x + w,
			y,
			true,
			false,
			segments,
			-pi_2,
			maxRoundAmount * rtCornerRoundPercent
		)
	else
		polys[#polys + 1] = {
			x = x + w,
			y = y
		}
	end

	-- right bottom corner
	if rbCornerRoundPercent ~= 0 then
		pushRoundedCorner(
			polys,
			x + w,
			y + h,
			true,
			true,
			segments,
			0,
			maxRoundAmount * rbCornerRoundPercent
		)
	else
		polys[#polys + 1] = {
			x = x + w,
			y = y + h
		}
	end

	-- left bottom corner
	if lbCornerRoundPercent ~= 0 then
		pushRoundedCorner(
			polys,
			x,
			y + h,
			false,
			true,
			segments,
			pi_2,
			maxRoundAmount * lbCornerRoundPercent
		)
	else
		polys[#polys + 1] = {
			x = x,
			y = y + h
		}
	end

	return polys
end

function x.PolyRoundedBox(
	x,
	y,
	w,
	h,
	segments,
	cornerRoundPercent
)
	return x.PolyRoundedBoxEx(
		x,
		y,
		w,
		h,
		segments,
		cornerRoundPercent,
		cornerRoundPercent,
		cornerRoundPercent,
		cornerRoundPercent
	)
end

--
-- OpenGL GL_TRIANGLE_STRIP draw poly method
--

local pointsBuffer	= {}
local polyBuffer	= {}
local swapBuffer	= false

local function pushBuffer(point)
	local point2 = pointsBuffer[2]
	local point3 = pointsBuffer[3]

	pointsBuffer[1] = point2
	pointsBuffer[2] = point3
	pointsBuffer[3] = point

	polyBuffer[2] = point2

	if swapBuffer then
		polyBuffer[1] = point3
		polyBuffer[3] = point
	else
		polyBuffer[1] = point
		polyBuffer[3] = point3
	end

	swapBuffer = not swapBuffer
end

function x.DrawTriangleStrip(points)
	swapBuffer = false

	pushBuffer(points[1])
	pushBuffer(points[2])

	for i = 3, #points do
		pushBuffer(points[i])

		drawPoly(polyBuffer)
	end
end

function x.DrawTriangleStripIndex(points, from, to)
	local indexStart = from + 2
	if indexStart > to then return end

	swapBuffer = from % 2 == 0

	pushBuffer(points[from])
	pushBuffer(points[from + 1])

	for i = indexStart, to do
		pushBuffer(points[i])

		drawPoly(polyBuffer)
	end
end

local function drawLinePoints(point1, point2)
	drawLine(point1.x, point1.y, point2.x, point2.y)
end

-- OpenGL GL_LINES
function x.DrawLines(points)
	local i = 1

	while i < #points do
		drawLinePoints(points[i], points[i + 1])

		i = i + 2
	end
end

-- OpenGL GL_LINE_STRIP
function x.DrawLineStrip(points)
	for i = 2, #points do
		drawLinePoints(points[i - 1], points[i])
	end
end

-- OpenGL GL_LINE_LOOP
function x.DrawLineLoop(points)
	x.DrawLineStrip(points)

	drawLinePoints(points[1], points[#points])
end
