-------------------------------------------------------------------------------
--- 关联容器，基于跳表实现有序字典集。
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
local __skiplist = newclass("__skiplist", require("luamon.container.traits.container"))
local __skiplist_max_level = 32

local function __skiplist_random_level()
    local level = 1
    while(math.random(1, 1000) < 250) do
        level = level + 1
    end
    return math.min(__skiplist_max_level, level)
end

function __skiplist:init(kcompare, kextract)
    -- 调整比较逻辑
    if (type(kcompare) ~= 'function') then
        kcompare = function(a, b)
            return a < b
        end
    end
    if (type(kextract) ~= 'function') then
        kextract = function(a)
            return a
        end
    end
    self.super:init("sequential")
    self.kcompare = kcompare
    self.kextract = kextract
    self.__level  = 1
    self.__count  = 0
    self.__header = 
    {
        links = {},
        value = nil
    }
    for i = 1, __skiplist_max_level do
        local node = {}
        node.span = 0
        node.prev = node
        node.next = node
        self.__header.links[i] = node
    end
end

function __skiplist:capacity()
    return 0x7FFFFFFF
end

function __skiplist:size()
    return self.__count
end

function __skiplist:empty()
    return (self:size() == 0)
end

function __skiplist:clear()
    self.__level  = 1
    self.__count  = 0
    self.__header = 
    {
        links = {},
        value = nil
    }
    for i = 1, __skiplist_max_level do
        local node = 
        {
            prev = self.__header,
            next = self.__header,
            span = 0,
        }
        self.__header.links[i] = node
    end
end

function __skiplist:insert(v)
    local rank  = {}
    local xpos  = {}
    local node  = { links = {}, value = v }
    local level = __skiplist_random_level()
    if (self.__level < level) then
        self.__level = level
    end
    -- 查找可插入点
    local x = self.__header.links[level]
    local e = self.__header.links[level]
    for i = level, 1, -1 do
        -- 更新排名记录
        if (i == level) then
            rank[i] = 0
        else
            rank[i] = rank[i + 1]
        end


    local x = self.__header.links[self.__level]
    local e = self.__header.links[self.__level]
    for i = 










-------------------------------------------------------------------------------
--- 迭代器
local __zset_iterator = newclass("__zset_iterator", require("luamon.container.traits.iterator"))

-------------------------------------------------------------------------------
--- 有序集
local zset = newclass("zset", require("luamon.container.traits.container"))