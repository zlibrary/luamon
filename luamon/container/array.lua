-------------------------------------------------------------------------------
--- A standard container for storing a fixed size sequence of elements.
-------------------------------------------------------------------------------
require "luamon.class"

local tointeger = math.tointeger
if (tointeger == nil) then
    tointeger = function(n)
        local i = tonumber(n)
        if (i ~= nil) and (i == math.floor(i)) then
            return i
        else
            return nil
        end
    end
end

---------------------------------------------------------------------
--- 'Array'基础结构
local __array_base = newclass('luamon.container.__array_base')

function __array_base:init(n)
    local nm = tointeger(n)
    if nm and (nm >= 0) then
        self.__size  = nm
        self.__elems = {}
    else
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", n, type(n)))
    end
end

---------------------------------------------------------------------
--- 'Array'迭代器
local __array_iterator = newclass('luamon.container.__array_iterator')

function __array_iterator(object, index)
    self._object = object
    self._index  = index
end

function __array_iterater



---------------------------------------------------------------------
--- 'Array'迭代器
local __array_iterator = newclass("luamon.container.__array_iterator")

-- 构造方法
function __array_iterator:init(array, index)





---------------------------------------------------------------------
--- "Array"基础结构
local __array_traits = newclass("__array_traits")

function __array_traits:init(n)
    local nm = tointeger(n)
    if nm and (nm >= 0) then
        self.__size  = nm
        self.__elems = {}
    else
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'", n, type(n)))
    end
end

---------------------------------------------------------------------
--- "Array"类型定义
local array = newclass("array", __array_traits)

function array:init(n)
    self.super:init(n)
end

