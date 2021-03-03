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
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", tostring(n), type(n)))
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

function __array_iterator:init(obj, idx)
    self.__obj = obj
    self.__idx = idx
end

function __array_iterator:get()
    return self.__obj:get(self.__idx)
end

function __array_iterator:set(v)
    self.__obj:set(self.__idx,v)
end

function __array_iterator:advance(n)
    local nm = tointeger(n)
    if (nm == nil) then
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", tostring(n), type(n)))
    else
        self.__idx = self.__idx + nm
        if (self.__idx < 1) then
            self.__idx = 1
        end
        if (self.__idx > self.__obj:size()) then
            self.__idx = self.__obj:size() + 1
        end
    end
end

function __array_iterator:__eq(v)
    if self.class() ~= v.class() then
        return false
    else
        return (self.__obj == v.__obj) and (self.__idx == v.__idx)
    end
end

function __array_iterator:__add(n)
    local nm = tointeger(n)
    if nm and (nm > 0) then
        local iterator = __array_iterator:new(self.__obj, self.__idx)
        iterator:advance(nm)
        return iterator
    else
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __array_iterator:__sub(n)
    local nm = tointeger(n)
    if nm and (nm > 0) then
        local iterator = __array_iterator:new(self.__obj, self.__idx)
        iterator:advance(-nm)
        return iterator
    else
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", tostring(n), type(n)))
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
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", tostring(n), type(n)))
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
        error(string.format("'%s[%s]' is not valid argument for type 'unsigned int'.", tostring(n), type(n)))
    else
        if (nm <= 0) or (nm > self.super:size()) then
            error("out of range.")
        else
            return self.super:set(nm, v)
        end
    end
end

function array:front()
    return __array_iterator:new(self.super, 1)
end

function array:rear()
    return __array_iterator:new(self.super, self.super:size() + 1)
end

return array
