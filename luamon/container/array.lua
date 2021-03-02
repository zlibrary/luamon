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

function __array_base:size()
    return self.__size
end

function __array_base:get(n)
    return self.__elems[n]
end

function __array_base:set(n, v)
    self.__elems[n] = v
end

---------------------------------------------------------------------
--- 'Array'迭代器
local __array_iterator = newclass('luamon.container.__array_iterator')

function __array_iterator(base, index)
    self.__base  = base
    self.__index = index
end

function __array_iterator:get()
    return self.__base:get(self.__index)
end

function __array_iterator:set(v)
    self.__base:set(self.__index, v)
end

function __array_iterator:advance(n)
    local nm = tointeger(n)
    if (nm == nil) then
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", n, type(n)))
    else
        self.__index = self.__index + nm
        if (self.__index < 1) then
            self.__index = 1
        end
        if (self.__index > self.__base:size()) then
            self.__index = self.__base:size() + 1
        end
    end
end

function __array_iterator:__eq(v1, v2)
    if (v1.class() ~= __array_iterator) or  (v1.class() ~= v2.class()) then
        return false
    else
        return (v1.__base == v2.__base) and (v1.__index == v2.__index)
    end
end

---------------------------------------------------------------------
--- 'Array'定义
local array = newclass('luamon.container.array', __array_base)

function array:init(n)
    self.super:init(n)
end

function array:size()
    return self.super:size()
end

function array:capacity()
    return self.super:size()
end

function array:empty()
    return (self.super:size() == 0)
end

function array:get(n)
    local nm = tointeger(n)
    if (nm == nil) then
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", n, type(n)))
    else
        if (nm <= 0) or (nm > self.super:size()) then
            error("out of range.")
        else
            return self.super:get(nm)
        end
    end
end

function array:set(n, v)
    local nm = tointeger(n)
    if (nm == nil) then
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", n, type(n)))
    else
        if (nm <= 0) or (nm > self.super:size()) then
            error("out of range.")
        else
            return self.super:set(nm, v)
        end
    end
end

function array:first()
    return __array_iterator:new(self.super, 1)
end

function array:rear()
    return __array_iterator:new(self.super, self.super:size() + 1)
end

