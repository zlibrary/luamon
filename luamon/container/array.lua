-------------------------------------------------------------------------------
--- A standard container for storing a fixed size sequence of elements.
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __array_iterator = newclass("__array_iterator")

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
    local nm = math.tointeger(n)
    if (nm == nil) then
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
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

function __array_iterator:__eq(other)
    if self.class() ~= other.class() then
        return false
    else
        return (self.__obj == other.__obj) and (self.__idx == other.__idx)
    end
end

function __array_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm > 0) then
        local iterator = __array_iterator:new(self.__obj, self.__idx)
        iterator:advance(nm)
        return iterator
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __array_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm > 0) then
        local iterator = __array_iterator:new(self.__obj, self.__idx)
        iterator:advance(-nm)
        return iterator
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 数组定义
local array = newclass("array", require("luamon.container.traits.container_traits"))

function array:init(n)
    self.super:init("sequential")
    if type(n) == "table" then
        if (array:super():made(n) == true) then
            assert(n.is_sequential(), string.format("'%s' isn't a sequential container.", tostring(n)))
            self.__size  = n:size()
            self.__elems = {}
            algorithm.copy(n:front(), n:rear(), self:front())
        else
            self.__size  = #n
            self.__elems = {}
            for _, v in ipairs(n) do
                table.insert(self.__elems, v)
            end
        end
    else
        local nm = math.tointeger(n)
        if nm and (nm >= 0) then
            self.__size  = nm
            self.__elems = {}
        else
            error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
        end
    end
end

function array:capacity()
    return self.__size
end

function array:size()
    return self.__size
end

function array:empty()
    return self.__size == 0
end

function array:get(n)
    local nm = math.tointeger(n)
    if nm then
        if (nm <= 0) or (nm > self:size()) then
            error("out of range.")
        else
            return self.__elems[nm]
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function array:set(n, v)
    local nm = math.tointeger(n)
    if nm then
        if (nm <= 0) or (nm > self:size()) then
            error("out of range.")
        else
            self.__elems[nm] = v
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function array:first()
    return self.front():get()
end

function array:last()
    return (self.rear() - 1):get()
end
    
function array:front()
    return __array_iterator:new(self, 1)
end

function array:rear()
    return __array_iterator:new(self, self:size() + 1)
end

return array
