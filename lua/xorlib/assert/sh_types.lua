xorlib.Dependency("xorlib/assert", "sh_assert.lua") -- x.Assert
xorlib.Dependency("xorlib/console", "sh_print.lua") -- x.Error

local type    = type
local IsValid = IsValid

function x.ExpectType(value, expectedType)
    local valueType = type(value)

    if valueType ~= expectedType then
        x.Error("expected type '%s', but got '%s'",
                expectedType,
                valueType)
    end

    return value
end

local expectType = x.ExpectType

function x.ExpectTypeOrDefault(value, expectedType, default)
    if value == nil then
        return default
    end

    return expectType(value, expectedType)
end

local function implExpectOrDefault(funcName)
    local expectFunction = x.Assert(x[funcName], "no expect function!")

    x[funcName .. "OrDefault"] = function(value, default)
        if value == nil then
            return default
        end

        return expectFunction(value)
    end
end

local function implExpect(funcName, type)
    local function expectFunction(value)
        return expectType(value, type)
    end

    x[funcName] = expectFunction

    implExpectOrDefault(funcName)
end

local validEntityTypes = {
    ["Entity"]  = true,
    ["Player"]  = true,
    ["Vehicle"] = true,
    ["Weapon"]  = true,
    ["NPC"]     = true,
    ["NextBot"] = true
}

function x.ExpectEntity(value)
    if not IsValid(value) or not validEntityTypes[type(value)] then
        x.Error("expected valid entity, but got '%s'",
                tostring(value))
    end

    return value
end

implExpectOrDefault("ExpectEntity")

function x.ExpectPlayer(value)
    if not IsValid(value) or type(value) ~= "Player" then
        x.Error("expected valid player, but got '%s'",
                tostring(value))
    end

    return value
end

implExpectOrDefault("ExpectPlayer")

implExpect("ExpectNumber",   "number")
implExpect("ExpectString",   "string")
implExpect("ExpectTable",    "table")
implExpect("ExpectBoolean",  "boolean")
implExpect("ExpectFunction", "function")
implExpect("ExpectVector",   "Vector")
implExpect("ExpectAngle",    "Angle")
