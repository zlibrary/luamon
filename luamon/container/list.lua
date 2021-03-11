-------------------------------------------------------------------------------
--- 序列容器，提供线性时间的查找以及在任意点进行常量时间的'插入/删除'操作.
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __list_iterator = newclass("__list_iterator", require("luamon.container.traits.iterator"))

function __list_iterator:init(node)
    self.super:init("bidirectional")
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
    return __list_iterator:new(self.__node[1])
end

function __list_iterator:next()
    return __list_iterator:new(self.__node[2])
end

function __list_iterator:__eq(other)
    return (self.class() == other.class()) and (self.__node == other.__node)
end

function __list_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __list_iterator:new(self.__node)
        iter:advance(n)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __list_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __list_iterator:new(self.__node)
        iter:advance(-n)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 链表定义
local list = newclass("list", require("luamon.container.traits.container"))

function list:xbegin()
    return __list_iterator:new(self.__node[2])
end

function list:xend()
    return __list_iterator:new(self.__node)
end

function list:rbegin()
    return iterator:rbegin(self)
end

function list:rend()
    return iterator:rend(self)
end

function list:init(obj)
    self.super:init("sequential")
    obj = obj or {}
    if (type(obj) == "table") then
        self.__node = {}
        self.__size = 0
        self.__node[1] = self.__node
        self.__node[2] = self.__node
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
    return (self:size() == 0)
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

function list:front()
    return self:xbegin():get()
end

function list:back()
    local tmp = self:xend()
    tmp = tmp - 1
    return tmp:get()
end
