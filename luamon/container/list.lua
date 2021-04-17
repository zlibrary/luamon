-------------------------------------------------------------------------------
--- 序列容器，提供线性时间的查找以及在任意点进行常量时间的'插入/删除'操作.
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __list_iterator = newclass("__list_iterator", require("luamon.container.traits.iterator"))

function __list_iterator:init(obj, node)
    self.super:init("bidirectional")
    self.__obj  = obj
    self.__node = node
end

function __list_iterator:get()
    return self.__node[3]
end

function __list_iterator:set(v)
    self.__node[3] = v
end

function __list_iterator:advance(n)
    local nm = math.tointeger(n)
    if nm then
        while(true) do
            if (nm == 0) then
                break
            end
            if (nm < 0) then
                nm = nm + 1
                self.__node = self.__node[1]
            else
                nm = nm - 1
                self.__node = self.__node[2]
            end
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __list_iterator:prev()
    return __list_iterator:new(self.__obj, self.__node[1])
end

function __list_iterator:next()
    return __list_iterator:new(self.__obj, self.__node[2])
end

function __list_iterator:distance(other)
    if (other.class == __list_iterator) and (self.__obj == other.__obj) then
        local c = self
        local n = 0
        while(c ~= other) do
            n = n + 1
            c = c + 1
        end
        return n
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function __list_iterator:__eq(other)
    return (other.class == __list_iterator) and (self.__obj == other.__obj) and (self.__node == other.__node)
end

function __list_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __list_iterator:new(self.__obj, self.__node)
        iter:advance(nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __list_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __list_iterator:new(self.__obj, self.__node)
        iter:advance(-nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 链表定义
local list = newclass("list", require("luamon.container.traits.container"))

function list:xbegin()
    return __list_iterator:new(self, self.__node[2])
end

function list:xend()
    return __list_iterator:new(self, self.__node)
end

function list:rbegin()
    return iterator:rbegin(self)
end

function list:rend()
    return iterator:rend(self)
end

function list:init(obj)
    self.super:init("sequential")
    self.__node = {}
    self.__size = 0
    self.__node[1] = self.__node
    self.__node[2] = self.__node
    -- 填充链表
    obj = obj or {}
    if (type(obj) == "table") then
        if (list:super():made(obj) == true) then
            assert(obj.is_sequential(), string.format("'%s' isn't sequential contianer.", tostring(obj)))
        end
        local curr = iterator:xbegin(obj)
        local last = iterator:xend(obj)
        while(curr ~= last) do
            self:push_back(curr:get())
            curr:advance(1)
        end
    else
        error(string.format("'%s[%s]' isn't valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function list:capacity()
    return 0x7FFFFFFF
end

function list:size()
    return self.__size
end

function list:empty()
    return (self.__size == 0)
end

function list:clear()
    self.__node = {}
    self.__size = 0
    self.__node[1] = self.__node
    self.__node[2] = self.__node
end

function list:resize(n, v)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local size = self:size()
        if (nm >= size) then
            for i = (size + 1), nm do
                self:push_back(v)
            end
        else
            for i = (nm + 1), size do
                self:pop_back()
            end
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function list:assign(obj)
    obj = obj or {}
    if (type(obj) == "table") then
        if (list:super():made(obj) == true) then
            assert(obj.is_sequential(), string.format("'%s' isn't sequential contianer.", tostring(obj)))
        else
            self:clear()
        end
        local curr = iterator:xbegin(obj)
        local last = iterator:xend(obj)
        while(curr ~= last) do
            self:push_back(curr:get())
            curr:advance(1)
        end
    else
        error(string.format("'%s[%s]' isn't valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function list:__insert_aux(p, v)
    self.__size = self.__size + 1
    local node = 
    {
        [1] = p[1],
        [2] = p,
        [3] = v,
    }
    p[1][2] = node
    p[1]    = node
    return node
end

function list:__erase_aux(p)
    if (p == self.__node) then
        return p
    else
        p[1][2] = p[2]
        p[2][1] = p[1]
        self.__size = self.__size - 1
        return p[2]
    end
end

function list:insert(pos, v)
    if (pos.class == __list_iterator) and (pos.__obj == self) then
        self:__insert_aux(pos.__node, v)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'iterator'.", tostring(pos), type(pos)))
    end
end

function list:erase(pos)
    if (pos.class == __list_iterator) and (pos.__obj == self) then
        self:__erase_aux(pos.__node)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'iterator'.", tostring(pos), type(pos)))
    end
end

function list:front()
    return self.__node[2][3]
end

function list:back()
    return self.__node[1][3]
end

function list:push_front(v)
    self:__insert_aux(self.__node[2], v)
end

function list:pop_front()
    self:__erase_aux(self.__node[2])
end

function list:push_back(v)
    self:__insert_aux(self.__node, v)
end

function list:pop_back()
    self:__erase_aux(self.__node[1])
end

function list:__len()
    return self:size()
end

function list:__pairs()
    local curr  = self:xbegin()
    local xend  = self:xend()
    local index = 0
    local value = nil
    return function()
        if (curr == xend) then
            return nil
        else
            value = curr:get()
            index = index + 1
            curr:advance(1)
            return index, value
        end
    end
end

return list
