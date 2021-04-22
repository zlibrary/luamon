-------------------------------------------------------------------------------
--- 关联容器，基于跳表实现有序字典集（以'value'作为排序条件）。
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
    while(math.random() < 0.5) do
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

local max = 0

function __skiplist:insert(v)
    local rank  = {}
    local xpos  = {}
    local node  = { links = {}, value = v }
    local level = __skiplist_random_level()
    if (self.__level < level) then
        self.__level = level
        print("level = ", level)
    end
    -- 查找可插入点
    local x = self.__header
    local e = self.__header
    local n = 0
    for i = self.__level, 1, -1 do
        if (i < self.__level) then
            rank[i] = rank[i + 1]
        else
            rank[i] = 0
        end
        -- 查找可插入点（当前等级）
        while(true) do
            local p = x.links[i].next
            -- if (p == e) or (self.kcompare(self.kextract(v), self.kextract(p.value)) == true) then
            if (p == e) then
                e = p
                break
            else
                x = p
                rank[i] = rank[i] + x.links[i].span
            end
            n = n + 1
        end
        xpos[i] = e
    end
    if n > max then
        max = n
        print(n)
    end
    -- 插入目标节点
    local p = __skiplist_node_new(level, v)
    for i = 1, level do
        local x = xpos[i].links[i].prev
        local e = xpos[i]
        local v = rank[1] - rank[i] + 1
        x.links[i].next = p
        e.links[i].prev = p
        p.links[i].prev = x
        p.links[i].next = e
        p.links[i].span = v
    end
    self.__count = (self.__count + 1)
    return p
end

function __skiplist:erase(p)
    if (p == self.__header) then
        return p
    end
    -- 记录后继节点
    local xpos = {}
    for i = 1, self.__level do
        if (p.links[i] == nil) then
            local x = xpos[i - 1]
            while(true) do
                if (x.links[i] ~= nil) then
                    break
                else
                    x = x.links[i - 1].next
                end
            end
            xpos[i] = x
        else
            xpos[i] = p.links[i].next
        end
    end
    -- 移除目标节点
    for i = 1, self.__level do
        local x = xpos[i]
        local v = 0
        if (x.links[i].prev == p) then
            local z = p.links[i].prev
            z.links[i].next = x
            x.links[i].prev = z
            v = p.links[i].span
        end
        if (x ~= self.__header) then
            x.links[i].span = x.links[i].span + (v - 1)
        end
    end
    self.__count = (self.__count - 1)
    return p.links[1].next
end

function __skiplist:at(n)
    local x = self.__header
    local e = self.__header
    local v = 0
    for i = self.__level, 1, -1 do
        while(true) do
            local p = x.links[i].next
            if (p == e) or (n < (v + p.links[i].span)) then
                break
            else
                x = p
                v = v + x.links[i].span
            end
        end
    end
    return (v == n) and x or e
end

function __skiplist:rank(p)
    local v = 0
    while(p ~= self.__header) do
        for i = self.__level, 1, -1 do
            if (p.links[i] ~= nil) then
                v = p.links[i].span + v
                p = p.links[i].prev
                break
            end
        end
    end
    return v
end

function __skiplist:find(k)
    local p = self:lower_bound(k)
    local e = self.__header
    if (p == e) or (self.kcompare(k, self.kextract(p.value))) then
        return e
    else
        return p
    end
end

function __skiplist:lower_bound(k)
    local x = self.__header
    local e = self.__header
    for i = self.__level, 1, -1 do
        while(true) do
            local p = x.links[i].next
            if (p == e) or (self.kcompare(self.kextract(p.value), k) == false) then
                e = p
                break
            else
                x = p
            end
        end
    end
    return e
end

function __skiplist:upper_bound(k)
    local x = self.__header
    local e = self.__header
    for i = self.__level, 1, -1 do
        while(true) do
            local p = x.links[i].next
            if (p == e) or (self.kcompare(k, self.kextract(p.value)) == true) then
                e = p
                break
            else
                x = p
            end
        end
    end
    return e
end

-------------------------------------------------------------------------------
--- 迭代器
local __zmap_iterator = newclass("__zmap_iterator", require("luamon.container.traits.iterator"))

function __zmap_iterator:init(inst, node)
    self.super:init("bidirectional")
    self.inst = inst
    self.node = node
end

function __zmap_iterator:get()
    return self.node.value
end

function __zmap_iterator:advance(n)
    local nm = math.tointeger(n)
    if nm then
        local rank = self.inst:rank(self.node)
        if (rank == 0) then
            rank = self.inst:size() + nm + 1
        else
            rank = rank + nm
        end
        self.node = self.inst:at(rank)
    else
        error(string.format("'%s[%s]' is invalid argument for type 'integer'.", tostring(n), type(n)))
    end
end

function __zmap_iterator:prev()
    local tmp = __zmap_iterator:new(self.inst, self.node)
    tmp:advance(-1)
    return tmp
end

function __zmap_iterator:next()
    local tmp = __zmap_iterator:new(self.inst, self.node)
    tmp:advance(1)
    return tmp
end

function __zmap_iterator:distance(other)
    if (other.class == __zmap_iterator) and (self.inst == other.inst) then
        local v1 = self.inst:rank( self.node)
        local v2 = self.inst:rank(other.node)
        if (v1 == 0) then
            v1 = self.inst:size() + 1
        end
        if (v2 == 0) then
            v2 = self.inst:size() + 1
        end
        return (v2 - v1)
    else
        error(string.format("'%s[%s]' not match 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function __zmap_iterator:__eq(other)
    return (other.class == __zmap_iterator) and (self.inst == other.inst) and (self.node == other.node)
end

function __zmap_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0)then
        local tmp = __zmap_iterator:new(self.inst, self.node)
        tmp:advance(nm)
        return tmp
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __zmap_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0)then
        local tmp = __zmap_iterator:new(self.inst, self.node)
        tmp:advance(-nm)
        return tmp
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 有序集
local zmap = newclass("zmap", require("luamon.container.traits.container"))

function zmap:xbegin()
    return __zmap_iterator:new(self.__linked, self.__linked.__header.links[1].next)
end

function zmap:xend()
    return __zmap_iterator:new(self.__linked, self.__linked.__header)
end

function zmap:rbegin()
    return iterator:rbegin(self)
end

function zmap:rend()
    return iterator:rend(self)
end

function zmap:init(compare)
    if (compare == nil) then
        compare = function(a, b)
            return a < b
        end
    end
    assert(type(compare) == "function", string.format("'%s[%s]' must be a 'function'.", tostring(compare), type(compare)))
    self.super:init("associated")
    self.__htable = {}
    self.__linked = __skiplist:new(compare, function(v) return v[2] end)
end

function zmap:capacity()
    return self.__linked:capacity()
end

function zmap:size()
    return self.__linked:size()
end

function zmap:empty()
    return self.__linked:empty()
end

function zmap:get(k)
    local p = self.__htable[k]
    if (p == nil) then
        return nil
    else
        return p.value[2]
    end
end

function zmap:set(k, v)
    local p = self.__htable[k]
    if (p == nil) then
        self.__htable[k] = self.__linked:insert({k, v})
    else
        self.__linked:erase(p) 
        self.__htable[k] = self.__linked:insert({k, v})
    end
end

function zmap:insert(k, v)
    local p = self.__htable[k]
    if (p == nil) then
        self.__htable[k] = self.__linked:insert({k, v})
        return true
    else
        return false
    end
end

function zmap:erase(pos)
    local k = nil
    local p = nil
    if (__zmap_iterator:made(pos) == true) and (pos.inst == self.__linked) then
        if (pos == self:xend()) then
            return
        else
            k = pos:get()[1]
            p = pos.node
        end
    else
        if (not self.__htable[pos]) then
            return
        else
            k = pos
            p = self.__htable[pos]
        end
    end
    self.__htable[k] = nil
    self.__linked:erase(p)
end

function zmap:clear()
    self.__htable={}
    self.__linked:clear()
end

function zmap:at(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0)then
        return __zmap_iterator:new(self.__linked, self.__linked:at(nm))
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function zmap:rank(k)
    local p = self.__htable[k]
    if (p == nil) then
        return 0
    else
        return self.__linked:rank(p)
    end
end

function zmap:find(k)
    local p = self.__htable[k]
    if (p == nil) then
        return self:xend()
    else
        return __zmap_iterator:new(self.__linked, p)
    end
end

function zmap:lower_bound(v)
    return __zmap_iterator:new(self.__linked, self.__linked:lower_bound(v))
end

function zmap:upper_bound(v)
    return __zmap_iterator:new(self.__linked, self.__linked:upper_bound(v))
end

function zmap:equal_range(v)
    return { self:lower_bound(v), self:upper_bound(v) }
end

function zmap:__len()
    return self:size()
end

function zmap:__pairs()
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

return zmap
