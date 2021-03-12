-------------------------------------------------------------------------------
--- 可变大小的序列容器，包含严格线性排列的可变数量元素.
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
local __vector_nil_mock = newclass("__vector_nil_mock")

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __vector_iterator = newclass("__vector_iterator", require("luamon.container.traits.iterator"))

function __vector_iterator:init(obj, idx)
    self.super:init("random-access")
    self.__obj = obj
    self.__idx = idx
end

function __vector_iterator:get()
    return self.__obj:get(self.__idx)
end

function __vector_iterator:set(v)
    self.__obj:set(self.__idx, v)
end

function __vector_iterator:advance(n)
    local nm = math.tointeger(n)
    if nm then
        self.__idx = self.__idx + nm
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __vector_iterator:prev()
    return __vector_iterator:new(self.__obj, (self.__idx - 1))
end

function __vector_iterator:next()
    return __vector_iterator:new(self.__obj, (self.__idx + 1))
end

function __vector_iterator:distance(other)
    if (other.class() == __vector_iterator) and (self.__obj == other.__obj) then
        return other.__idx - self.__idx
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function __vector_iterator:__eq(other)
    return (self.class() == other.class()) and (self.__obj == other.__obj) and (self.__idx == other.__idx)
end

function __vector_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        return __vector_iterator:new(self.__obj, self.__idx + nm)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __vector_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        return __vector_iterator:new(self.__obj, self.__idx - nm)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 容器定义（变长数组）
local vector = newclass("vector", require("luamon.container.traits.container"))

function vector:xbegin()
    return __vector_iterator:new(self, 1)
end

function vector:xend()
    return __vector_iterator:new(self, self:size() + 1)
end

function vector:rbegin()
    return iterator:rbegin(self)
end

function vector:rend()
    return iterator:rend(self)
end

function vector:init(obj)
    self.super:init("sequential")
    obj = obj or {}
    if (type(obj) == "table") then
        self.__elems = {}
        if (vector:super():made(obj) == true) then
            assert(obj.is_sequential(), string.format("'%s' isn't sequential contianer.", tostring(obj)))
        end
        local curr = iterator:xbegin(obj)
        local last = iterator:xend(obj)
        while(curr ~= last) do
            table.insert(self.__elems, curr:get() or __vector_nil_mock)
            curr:advance(1)
        end
    else
        error(string.format("'%s[%s]' isn't valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function vector:capacity()
    return 0x7FFFFFFF
end

function vector:size()
    return #(self.__elems)
end

function vector:empty()
    return (self:size() == 0)
end

function vector:resize(n, v)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local size = self:size()
        if (nm >= size) then
            for i = (size + 1), nm do
                table.insert(self.__elems, v or __vector_nil_mock)
            end
        else
            local elems = {}
            for i = 1, nm do
                table.insert(elems, self.__elems[i])
            end
            self.__elems = elems
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function vector:get(n)
    local nm = math.tointeger(n)
    if nm then
        local val = self.__elems[nm]
        if val == __vector_nil_mock then
            return nil
        else
            return val
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function vector:set(n, v)
    local nm = math.tointeger(n)
    if nm then
        if (nm > 0) and (nm <= self:size()) then
            self.__elems[nm] = v or __vector_nil_mock
        else
            error("out of range.")
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function vector:front()
    return self:get(1)
end

function vector:back()
    return self:get(self:size())
end

function vector:assign(obj)
    obj = obj or {}
    if (type(obj) == "table") then
        self.__elems = {}
        if (vector:super():made(obj) == true) then
            assert(obj.is_sequential(), string.format("'%s' isn't sequential contianer.", tostring(obj)))
        end
        local curr = iterator:xbegin(obj)
        local last = iterator:xend(obj)
        while(curr ~= last) do
            table.insert(self.__elems, curr:get() or __vector_nil_mock)
            curr:advance(1)
        end
    else
        error(string.format("'%s[%s]' isn't valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function vector:insert(pos, v)
    if (pos.class() == __vector_iterator) and (pos.__obj == self) then
        table.insert(self.__elems, pos.__idx, v or __vector_nil_mock)
        return pos
    else
        error(string.format("'%s[%s]' is invalid argument for type 'iterator'.", tostring(pos), type(pos)))
    end
end

function vector:erase(pos)
    if (pos.class() == __vector_iterator) and (pos.__obj == self) then
        table.remove(self.__elems, pos.__idx)
        return pos
    else
        error(string.format("'%s[%s]' is invalid argument for type 'iterator'.", tostring(pos), type(pos)))
    end
end

function vector:clear()
    self.__elems = {}
end

function vector:push_back(v)
    self:insert(self:xend(), v)
end

function vector:pop_back()
    table.remove(self.__elems)
end

function vector:__len()
    return self:size()
end

function vector:__pairs()
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

return vector
