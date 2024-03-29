xorlib.Dependency("xorlib/assert", "sh_assert.lua") -- x.Assert
xorlib.Dependency("xorlib/functional", "sh_getters.lua") -- x.Meta

local select = select
local getmetatable = getmetatable

local PLACEHOLDER = {}

do
    local function createPlaceholder(index)
        return setmetatable({ Index = index }, PLACEHOLDER)
    end

    x._1 = createPlaceholder(1)
    x._2 = createPlaceholder(2)
    x._3 = createPlaceholder(3)
    x._4 = createPlaceholder(4)
    x._5 = createPlaceholder(5)
    x._6 = createPlaceholder(6)
    x._7 = createPlaceholder(7)
    x._8 = createPlaceholder(8)
    x._9 = createPlaceholder(9)
end

-- For placeholders use xorlib._[1-9]
--
-- Still faster than args = { ... } and unpack(args)
function x.Bind(f, ...)
    local argc = select("#", ...)
    x.Assert(argc <= 9, "Max bind arguments is 9")

    -- BA*
    -- Bind Argument <Argument Index>
    local ba1, ba2, ba3, ba4, ba5, ba6, ba7, ba8, ba9 = ...

    -- MA*
    -- Modified Argument <Argument Index>
    local bindArguments = {
        [1] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ba1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9 end,
        [2] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ba2, ma3, ma4, ma5, ma6, ma7, ma8, ma9 end,
        [3] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ba3, ma4, ma5, ma6, ma7, ma8, ma9 end,
        [4] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ma3, ba4, ma5, ma6, ma7, ma8, ma9 end,
        [5] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ma3, ma4, ba5, ma6, ma7, ma8, ma9 end,
        [6] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ma3, ma4, ma5, ba6, ma7, ma8, ma9 end,
        [7] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ma3, ma4, ma5, ma6, ba7, ma8, ma9 end,
        [8] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ba8, ma9 end,
        [9] = function(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9) return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ba9 end,
    }

    -- swapArguments[<f argument num>][<bind_f argument num>]
    --
    -- OA*
    -- Original Argument <Argument Index>
    -- (input argument from <f>)
    --
    -- MA*
    -- Modified Argument <Argument Index>
    local swapArguments = {
        [1] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa1, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa1, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa1, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa1, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa1, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa1, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa1, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa1
            end
        },
        [2] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa2, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa2, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa2, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa2, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa2, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa2, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa2, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa2
            end
        },
        [3] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa3, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa3, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa3, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa3, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa3, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa3, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa3, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa3
            end
        },
        [4] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa4, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa4, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa4, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa4, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa4, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa4, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa4, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa4, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa4
            end
        },
        [5] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa5, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa5, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa5, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa5, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa5, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa5, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa5, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa5, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa5
            end
        },
        [6] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa6, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa6, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa6, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa6, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa6, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa6, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa6, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa6, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa6
            end
        },
        [7] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa7, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa7, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa7, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa7, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa7, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa7, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa7, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa7, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa7
            end
        },
        [8] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa8, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa8, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa8, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa8, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa8, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa8, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa8, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa8, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa8
            end
        },
        [9] = {
            [1] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return oa9, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [2] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, oa9, ma3, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [3] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, oa9, ma4, ma5, ma6, ma7, ma8, ma9
            end,
            [4] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, oa9, ma5, ma6, ma7, ma8, ma9
            end,
            [5] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, oa9, ma6, ma7, ma8, ma9
            end,
            [6] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, oa9, ma7, ma8, ma9
            end,
            [7] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, oa9, ma8, ma9
            end,
            [8] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, oa9, ma9
            end,
            [9] = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                           ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, oa9
            end
        },
    }

    local function modifyArguments(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                                   ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
        return ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
    end

    for i = 1, argc do
        local oModifyArguments = modifyArguments
        local arg = select(i, ...)

        if getmetatable(arg) == PLACEHOLDER then
            local swap = swapArguments[arg.Index][i]

            modifyArguments = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                                       ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9 = swap(
                    oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                    ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9
                )

                return oModifyArguments(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                                        ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
            end
        else
            local bind = bindArguments[i]

            modifyArguments = function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                                       ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
                ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9 = bind(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)

                return oModifyArguments(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
                                        ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
            end
        end
    end

    return function(oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9)
        local ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9 = modifyArguments(
            oa1, oa2, oa3, oa4, oa5, oa6, oa7, oa8, oa9,
            nil, nil, nil, nil, nil, nil, nil, nil, nil
        )

        return f(ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9)
    end
end

function x.BindMeta(meta, name, ...)
    return x.Bind(x.Meta(meta, name), ...)
end
