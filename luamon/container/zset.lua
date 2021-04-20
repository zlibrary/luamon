-------------------------------------------------------------------------------
--- 关联容器，基于跳表实现有序字典集。
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 跳表
local __skiplist = newclass("__skiplist", require("luamon.container.traits.container"))
local __skiplist_max_level = 32

local function __skiplist_node_new(level, value)
    local node = 
    {
        value = value,
        links = {},
    }
    for i = 1, level do
        node.links[i] = 
        {
            span = 0,
            prev = node,
            next = node,
        }
    end
    return node
end

local function __skiplist_random_level()
    local level = 1
    while(math.random() < 0.25) do
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
    self.__header = __skiplist_node_new(__skiplist_max_level)
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
    self.__header = __skiplist_node_new(__skiplist_max_level)
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
    local x = self.__header
    local e = self.__header
    for i = level, 1, -1 do
        if (i < level) then
            rank[i] = rank[i + 1]
        else
            rank[i] = 0
        end
        -- 查找可插入点（当前等级）
        while(true) do
            local p = x.links[i].next
            if (p == e) or (self.kcompare(self.kextract(v), p.value) == false) then
                e = p
                break
            else
                x = p
                rank[i] = rank[i] + x.links[i].span
            end
        end
        xpos[i] = e
    end
    -- 插入目标节点
    local p = __skiplist_node_new(level, v)
    for i = 1, level do
        local x = xpos[i].prev
        local e = xpos[i]
        x.links[i].next = p
        e.links[i].prev = p
        p.links[i].prev = x
        p.links[i].next = e
        p.linls[i].span = rank[1] - rank[i] + 1 
    end
    self.__count = self.__count + 1
    return p
end

function __skiplist:erase(p)
    if (p == self.__header) then
        return p
    end
    -- 删除目标节点
    for i = 1, __skiplist_max_level do
        if (p.links[i] == nil) then
            break
        end
        local x = p.links[i].prev
        local e = p.links[i].next
        x.links[i].next = e
        e.links[i].prev = x
        if (e ~= self.__header) then
            e.links[i].span = e.links[1].span + p.links[i].span - 1
        end
    end
    self.__count = self.__count - 1
    return p.links[1].next
end

function __skiplist:lower_bound(k)
    local x = self.__header
    local e = self.__header
    for i = self.__level, 1, -1 do
        while(true) do
            local p = x.links[i].next
            if (p == e) or 


        -- 查找可插入点（当前等级）
        while(true) do
            local p = x.links[i].next
            if (p == e) or (self.kcompare(self.kextract(v), p.value) == false) then
                e = p
                break
            else
                x = p
                rank[i] = rank[i] + x.links[i].span
            end
        end
        xpos[i] = e
    end



-------------------------------------------------------------------------------
--- 迭代器
local __zset_iterator = newclass("__zset_iterator", require("luamon.container.traits.iterator"))

-------------------------------------------------------------------------------
--- 有序集
local zset = newclass("zset", require("luamon.container.traits.container"))