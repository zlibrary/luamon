-------------------------------------------------------------------------------
--- 关联容器。在哈希表的基础上增加了双向链表，使其具有可预测的迭代顺序。
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local list      = require "luamon.container.list"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 容器定义
local map = newclass("linked-hashmap", require("luamon.container.traits.container"))

function map:xbegin()
    return self.__linked:xbegin()
end

function map:xend()
    return self.__linked:xend()
end

function map:rbegin()
    return iterator:rbegin(self)
end

function map:rend()
    return iterator:rend(self)
end

function map:init(access_order)
    self.super:init("associated")
    self.__htable  = {}
    self.__linked  = list:new()
    self.__mutable = (not (not access_order))
end

function map:size()
    return self.__linked:size()
end

function map:empty()
    return self.__linked:empty()
end

function map:capacity()
    return self.__linked:capacity()
end

function map:get(k)
    local node = self.__htable[k]
    if (node == nil) then
        return nil
    else
        local v = node:get()
        if (self.__mutable == true) then
            self.__linked:push_back(v)
            self.__linked:erase(node)
        end
        return v[2]
    end
end

function map:set(k, v)
    local node = self.__htable[k]
    if (node == nil) then
        self.__htable[k] = self.__linked:insert(self.__linked:xend(), {k, v})
    else
        if (self.__mutable == true) then
            self.__linked:push_back(node:get())
            self.__linked:erase(node)
            node = self.__linked:xend() - 1
        end
        node:set({k, v})
        self.__htable[k] = node
    end
end

function map:insert(k, v)
    local node = self.__htable[k]
    if (node == nil) then
        self.__htable[k] = self.__linked:insert(self.__linked:xend(), {k, v})
    else
        return false
    end
end

function map:erase(k)
    if require("luamon.container.traits.iterator"):made(k) then
        k = k:get()[1]
    end
    local i = self.__htable[k]
    self.__htable[k] = nil
    self.__linked:erase(i)
end

function map:clear()
    self.__htable  = {}
    self.__linked  = list:new()
end

function map:find(k)
    local node = self.__htable[k]
    if (node == nil) then
        return self:xend()
    else
        if (self.__mutable == true) then
            self.__linked:push_back(node:get())
            self.__linked:erase(node)
            self.__htable[k] = self:xend() - 1
        end
        return self.__htable[k]
    end
end

function map:count(k)
    return (self:xend() == self:find(k)) and 0 or 1
end

function map:__len()
    return self:size()
end

function map:__pairs()
    local curr  = self:xbegin()
    local xend  = self:xend()
    local value = nil
    return function()
        if (curr == xend) then
            return nil
        else
            value = curr:get()
            curr:advance(1)
            return value[1], value[2]
        end
    end
end

return map
