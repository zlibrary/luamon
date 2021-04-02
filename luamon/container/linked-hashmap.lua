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
end

function map:xend()
end

function map:rbegin()
    return iterator:rbegin(self)
end

function map:rend()
    return iterator:rend(self)
end

function map:init(mutable)
    self.super:init("associated")
    self.__htable  = {}
    self.__linked  = list:new()
    self.__mutable = not not mutable
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
end

function map:set(k, v)
end

function map:insert(k, v)


