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

function map:init()

