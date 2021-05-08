-------------------------------------------------------------------------------
--- 迭代器辅助方法集
-------------------------------------------------------------------------------
require "luamon"
local container = require "luamon.container.traits.container"

-------------------------------------------------------------------------------
--- 迭代器（反向）
local reverse_iterator = newclass("luamon.container.reverse_iterator", require("luamon.container.traits.iterator"))

function reverse_iterator:init(iterator)
    self.super:init(iterator:name())
    self.__iterator = iterator
end

function reverse_iterator:base()
    return self.__iterator
end

function reverse_iterator:get()
    return (self.__iterator - 1):get()
end

function reverse_iterator:set(v)
    (self.__iterator - 1):set(v)
end

function reverse_iterator:advance(n)
    self.__iterator:advance(-n)
end

function reverse_iterator:prev()
    return reverse_iterator:new(self.__iterator + 1)
end

function reverse_iterator:next()
    return reverse_iterator:new(self.__iterator - 1)
end

function reverse_iterator:distance(other)
    if other.class == reverse_iterator then
        return other.__iterator:distance(self.__iterator)
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function reverse_iterator:__eq(other)
    return (self.__iterator == other.__iterator)
end

function reverse_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        return reverse_iterator:new(self.__iterator - nm)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function reverse_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        return reverse_iterator:new(self.__iterator + nm)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 迭代器（'table')
local table_iterator = newclass("luanom.container.table_iterator", require("luamon.container.traits.iterator"))

function table_iterator:init(tbl, idx)
    self.super:init("random-access")
    self.__tbl = tbl
    self.__idx = idx
end

function table_iterator:get()
    return self.__tbl[self.__idx]
end

function table_iterator:set(v)
    self.__tbl[self.__idx] = v
end

function table_iterator:advance(n)
    local nm = math.tointeger(n)
    if nm then
        self.__idx = self.__idx + nm
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function table_iterator:prev()
    return table_iterator:new(self.__tbl, (self.__idx - 1))
end

function table_iterator:next()
    return table_iterator:new(self.__tbl, (self.__idx + 1))
end

function table_iterator:distance(other)
    if (other.class == table_iterator) and (self.__tbl == other.__tbl) then
        return other.__idx - self.__idx
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function table_iterator:__eq(other)
    return (other.class == table_iterator) and (self.__tbl == other.__tbl) and (self.__idx == other.__idx)
end

function table_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        return table_iterator:new(self.__tbl, (self.__idx + nm))
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function table_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        return table_iterator:new(self.__tbl, (self.__idx - nm))
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 迭代器方法集
local iterator = {}

function iterator:xbegin(obj)
    if (type(obj) == "table") then
        if not container:made(obj) then
            return table_iterator:new(obj, 1)
        else
            return obj:xbegin()
        end
    else
        error(string.format("'%s[%s]' is not valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function iterator:xend(obj)
    if (type(obj) == "table") then
        if not container:made(obj) then
            return table_iterator:new(obj, #obj + 1)
        else
            return obj:xend()
        end
    else
        error(string.format("'%s[%s]' is not valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function iterator:rbegin(obj)
    if (type(obj) == "table") then
        if not container:made(obj) then
            return reverse_iterator:new(table_iterator(obj, #obj + 1))
        else
            return reverse_iterator:new(obj:xend())
        end
    else
        error(string.format("'%s[%s]' is not valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function iterator:rend(obj)
    if (type(obj) == "table") then
        if not container:made(obj) then
            return reverse_iterator:new(table_iterator(obj, 1))
        else
            return reverse_iterator:new(obj:xbegin())
        end
    else
        error(string.format("'%s[%s]' is not valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

return iterator
