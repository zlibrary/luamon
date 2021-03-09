-------------------------------------------------------------------------------
--- 固定大小的序列容器，包含严格线性排列的特定数量元素.
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __array_iterator = newclass("__array_iterator", require("luamon.container.traits.iterator"))

function __array_iterator:init(obj, idx)
    self.super:init("random-access")
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
        local idx = self.__idx + nm
        if (idx >= 1) and (idx <= (self.__obj:size() + 1)) then
            self.__idx = idx
        else
            error("out of range.")
        end
    end
end

function __array_iterator:prev()
    local iterator = __array_iterator:new(self.__obj, self.__idx)
    iterator:advance(-1)
    return iterator
end

function __array_iterator:next()
    local iterator = __array_iterator:new(self.__obj, self.__idx)
    iterator:advance(1)
    return iterator
end

function __array_iterator:__eq(other)
    return (self.class() == other.class()) and (self.__obj == other.__obj) and (self.__idx == other.__idx)
end

function __array_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
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
--- 容器定义（定长数组）
local array = newclass("array", require("luamon.container.traits.container"))

function array:xbegin()
    return __array_iterator:new(self, 1)
end

function array:xend()
    return __array_iterator:new(self, self:size() + 1)
end

function array:rbegin()
    return iterator:rbegin(self)
end

function array:rend()
    return iterator:rend(self)
end

function array:init(n)
    self.super:init("sequential")
    if type(n) == "table" then
        if (array:super():made(n) == true) then
            assert(n.is_sequential(), string.format("'%s' isn't a sequential container.", tostring(n)))
            self.__size  = n:size()
            self.__elems = {}
            algorithm.copy(n:xbegin(), n:xend(), self:xbegin())
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
        if (nm < 1) or (nm > self:size()) then
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
        if (nm < 1) or (nm > self:size()) then
            error("out of range.")
        else
            self.__elems[nm] = v
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function array:front()
    if self:empty() then
        return nil
    else
        return self.__elems[1]
    end
end

function array:back()
    if self:empty() then
        return nil
    else
        return self.__elems[self.__size]
    end
end

function array:__len()
    return self.__size
end

function array:__pairs()
    local curr = self:xbegin()
    local xend = self:xend()
    return function()
        if (curr == xend) then
            return nil
        else
            local idx = curr.__idx
            local val = curr:get()
            curr:advance(1)
            return idx, val
        end
    end
end

return array
