local sin		= math.sin
local cos		= math.cos
local drawPoly	= surface.DrawPoly
local drawLine	= surface.DrawLine
local pi2		= math.pi * 2

function x.PolyCircle(x, y, fill, segments, radius, rotation)
	local polygons		= {}
	local step			= (pi2 * fill) / segments
	local indexOffset

	if fill ~= 1 then
		indexOffset = 1

		polygons[1] = {
			x = x,
			y = y
		}
	else
		indexOffset = 0
	end

	for i = 0, segments do
		local angle = i * step

		polygons[i + 1 + indexOffset] = {
			x = x + (cos(angle + rotation) * radius),
			y = y + (sin(angle + rotation) * radius)
		}
	end

	return polygons
end

-- !!! use ONLY with DrawTriangleStrip* functions !!!
function x.PolyArc(x, y, thickness, fill, segments, radius, rotation)
	local polys			= {}
	local step			= (pi2 * fill) / segments
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
