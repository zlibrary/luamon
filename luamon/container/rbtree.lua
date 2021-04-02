-------------------------------------------------------------------------------
--- 红黑树， 被设计作为关联容器的底层组件。
--- 红黑树的构成规则
--- 1. 每个节点不是红色就是黑色
--- 2. 根总是黑色
--- 3. 相邻的节点不能同时为红色
--- 4. 任意节点到可达外部节点的路径包含相同数目的黑色节点
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __rbtree_iterator = newclass("__rbtree_iterator", require("luamon.container.traits.iterator"))

function __rbtree_iterator:init(inst, node)
    self.super:init("bidirectional")
    self.inst = inst
    self.node = node
end

function __rbtree_iterator:get()
    return self.node.value
end

function __rbtree_iterator:set(v)
    self.node.value = v
end

function __rbtree_iterator:increment()
    if (self.node == self.inst.header) then
        return
    else
        if (self.node.rchild ~= nil) then
            self.node = self.node.rchild
            while(self.node.lchild) do
                self.node = self.node.lchild
            end
        else
            local p = self.node.parent
            local x = self.node
            while(x == p.rchild) do
                x = p
                p = p.parent
            end
            if (x == self.inst.header) then
                self.node = x
            else
                self.node = p
            end
        end
    end
end

function __rbtree_iterator:decrement()
    if (self.node == self.inst.header) then
        self.node =  self.node.rchild
    else
        if (self.node.lchild ~= nil) then
            self.node = self.node.lchild
            while(self.node.rchild) do
                self.node = self.node.rchild
            end
        else
            local p = self.node.parent
            local x = self.node
            while(x == p.lchild) do
                x = p
                p = p.parent
            end
            if (x == self.inst.header) then
                self.node = x
            else
                self.node = p
            end
        end
    end
end

function __rbtree_iterator:advance(n)
    local nm = math.tointeger(n)
    if nm then
        while(true) do
            if (nm == 0) then
                break
            end
            if (nm < 0) then
                nm = nm + 1
                self:decrement()
            else
                nm = nm - 1
                self:increment()
            end
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __rbtree_iterator:prev()
    local tmp = __rbtree_iterator:new(self.inst, self.node)
    tmp:decrement()
    return tmp
end

function __rbtree_iterator:next()
    local tmp = __rbtree_iterator:new(self.inst, self.node)
    tmp:increment()
    return tmp
end

function __rbtree_iterator:distance(other)
    if (other.class == __rbtree_iterator) and (self.inst == other.inst) then
        local e = self.inst:xend()
        local c = self
        local n = 0
        while(true) do
            if (c == other) then
                return n
            end
            if (c == e) then
                error("iterator:distance() overflow.")
            else
                n = n + 1
                c = c + 1
            end
        end
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function __rbtree_iterator:__eq(other)
    return (other.class == __rbtree_iterator) and (self.inst == other.inst) and (self.node == other.node)
end

function __rbtree_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local tmp = __rbtree_iterator:new(self.inst, self.node)
        tmp:advance(nm)
        return tmp
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __rbtree_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local tmp = __rbtree_iterator:new(self.inst, self.node)
        tmp:advance(-nm)
        return tmp
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
local __rbtree_color_red   = 1
local __rbtree_color_black = 2

local function __rbtree_begin(x)
    return x.header.parent
end

local function __rbtree_end(x)
    return x.header
end

local function __rbtree_root(x)
    return x.header.parent
end

local function __rbtree_minimum(x)
    return x.header.lchild
end

local function __rbtree_maximum(x)
    return x.header.rchild
end

local function __rbnode_minimum(x)
    while(x.lchild) do
        x = x.lchild
    end
    return x
end

local function __rbnode_maximum(x)
    while(x.rchild) do
        x = x.rchild
    end
    return x
end

local function __rbtree_rotate_l(this, x)
    local y  = x.rchild
    x.rchild = y.lchild
    if (y.lchild ~= nil) then
        y.lchild.parent = x
    end
    y.parent = x.parent
    if (this.header.parent == x) then
        this.header.parent = y
    else
        if (x.parent.lchild == x) then
            x.parent.lchild = y
        else
            x.parent.rchild = y
        end
    end
    y.lchild = x
    x.parent = y
end

local function __rbtree_rotate_r(this, x)
    local y  = x.lchild
    x.lchild = y.rchild
    if (y.rchild ~= nil) then
        y.rchild.parent = x
    end
    y.parent = x.parent
    if (this.header.parent == x) then
        this.header.parent = y
    else
        if (x.parent.lchild == x) then
            x.parent.lchild = y
        else
            x.parent.rchild = y
        end
    end
    y.rchild = x
    x.parent = y
end

local function __rbtree_get_insert_unique_pos(this, k)
    local x = __rbtree_begin(this)
    local y = __rbtree_end(this)
    local c = true
    while(x ~= nil) do -- 向下查找合适插入的叶节点
        y = x
        c = this.kcompare(k, this.kextract(x.value))
        if c then
            x = x.lchild
        else
            x = x.rchild
        end
    end
    local j = __rbtree_iterator:new(this, y)
    if c then
        -- 新键值作为'j'的左孩子插入
        if (this:xbegin() == j) then
            -- 'y'是首节点（无需后退检查是否存在重复键值）
            return {x, y}
        else
            -- 'y'非首节点（需要后退检查是否存在重复键值）
            j:decrement()
        end
    end
    if (this.kcompare(this.kextract(j:get()), k)) then
        return {x, y} -- 没有重复键值
    else
        return {j.__node, nil}
    end
end

local function __rbtree_get_insert_equal_pos(this, k)
    local x = __rbtree_begin(this)
    local y = __rbtree_end(this)
    while(x ~= nil) do -- 向下查找合适插入的叶节点
        y = x
        if this.kcompare(k, this.kextract(x.value)) then
            x = x.lchild
        else
            x = x.rchild
        end
    end
    return {x, y}
end

local function __rbtree_insert_aux(this, p, v)
    -- 节点插入操作
    local linsert = (p == this.header) or (this.kcompare(this.kextract(v), this.kextract(p.value)))
    local x = 
    {
        parent = p,
        color  = __rbtree_color_red,
        value  = v,
    }
    if linsert then
        -- 作为左节点插入
        p.lchild = x
        if (this.header == p) then
            this.header.parent = x
            this.header.rchild = x
        end
        if (this.header.lchild == p) then
            this.header.lchild = x
        end
    else
        -- 作为右节点插入
        p.rchild = x
        if (this.header.rchild == p) then
            this.header.rchild = x
        end
    end
    -- 红黑树平衡
    while((this.header.parent ~= x) and (x.color == __rbtree_color_red)) do
        local g = x.parent.parent
        local p = x.parent
        local u = nil
        if (p == g.lchild) then
            u =  g.rchild
        else
            u =  g.lchild
        end
        if (p.color == __rbtree_color_black) then
            break
        end
        if u and (u.color == __rbtree_color_red) then
            -- 重新染色
            g.color = __rbtree_color_red
            p.color = __rbtree_color_black
            u.color = __rbtree_color_black
            x = g
        else
            -- 结构调整
            if (p == g.lchild) then
                if (x == p.rchild) then
                    __rbtree_rotate_l(this, p)
                    p = x
                    x = p.lchild
                end
                __rbtree_rotate_r(this, g)
                -- 重新染色
                g.color = __rbtree_color_red
                x.color = __rbtree_color_red
                p.color = __rbtree_color_black
            else
                if (x == p.lchild) then
                    __rbtree_rotate_r(this, p)
                    p = x
                    x = p.rchild
                end
                __rbtree_rotate_l(this, g)
                -- 重新染色
                g.color = __rbtree_color_red
                x.color = __rbtree_color_red
                p.color = __rbtree_color_black
            end
            x = p
        end
    end
    this.header.parent.color = __rbtree_color_black
    this.count = this.count + 1
    return x
end

local function __rbtree_erase_aux(this, z)
    -- 节点移除操作
    local y = z
    local x = nil
    local p = nil
    if (y.lchild == nil) or (y.rchild == nil) then
        -- 'z'节点最多存在一个子节点(可以直接移除)
        x = (y.lchild == nil) and y.rchild or y.lchild
    else
        -- 'z'节点同时存在左右子节点(查找后继节点)
        y = y.rchild
        while(y.lchild) do
            y = y.lchild
        end
        x = y.rchild
    end
    -- 'y'指向要删除的节点(可能是'z', 也可能是'z'的后继节点)
    -- 'y'最多存在一个子节点, 'x'则指向可能存在的子节点
    if (y ~= z) then
        -- 'y'是'z'的后继(需要交换位置)
        z.lchild.parent = y
        y.lchild = z.lchild
        if (y ~= z.rchild) then
            p = y.parent -- 记录'y'的父节点
            if (x ~= nil) then
                x.parent = p
            end
            p.lchild = x
            y.rchild = z.rchild
            z.rchild.parent = y
        else
            p = y
        end
        if (this.header.parent == z) then
            this.header.parent = y
        else
            if (z.parent.lchild == z) then
                z.parent.lchild = y
            else
                z.parent.rchild = y
            end
        end
        y.parent = z.parent
        y.color, z.color = z.color, y.color
        y = z
    else
        p = y.parent
        if (x ~= nil) then
            x.parent = p
        end
        if (this.header.parent == z) then
            this.header.parent = x
        else
            if (p.lchild == z) then
                p.lchild = x
            else
                p.rchild = x
            end
        end
        -- 更新最大/最小元素(上一分支无需处理,因为'z'肯定不是)
        if (this.header.lchild == z) then
            if (z.rchild == nil) then
                this.header.lchild = z.parent
            else
                this.header.lchild = __rbnode_minimum(x)
            end
        end
        if (this.header.rchild == z) then
            if (z.lchild == nil) then
                this.header.rchild = z.parent
            else
                this.header.rchild = __rbnode_maximum(x)
            end
        end
    end
    -- 'y'已经移除的节点
    -- 'p'父节点
    -- 'x'可能存在的子节点
    if (y.color == __rbtree_color_black) then
        while(true) do
            if (x == this.header.parent) then
                break -- 'x'为根节点（即'y'为根节点，且仅有一个孩子'x'）， 仅需将'x'染黑即可
            end
            if (x ~= nil) and (x.color == __rbtree_color_red) then
                break -- 'x'存在且为红色，仅需将'x'染黑即可
            end
            if (x == p.lchild) then
                local s = p.rchild
                if (s.color == __rbtree_color_red) then
                    -- 'BB-3'转换为'BB-1'
                    -- 'x' = 任意
                    -- 'p' = 黑色
                    -- 's' = 红色
                    s.color = __rbtree_color_black
                    p.color = __rbtree_color_red
                    __rbtree_rotate_l(this, p)
                    s = p.rchild
                end
                if ((s.lchild == nil) or (s.lchild.color == __rbtree_color_black)) and
                   ((s.rchild == nil) or (s.rchild.color == __rbtree_color_black)) then
                    -- 'BB-2' : 调整'p'树平衡（高度降低，需要向上传递）
                    -- 'p' = 任意颜色
                    -- 'x' = 任意颜色
                    -- 's' = 黑色，且两个孩子均不是红色
                    s.color = __rbtree_color_red
                    x = p
                    p = x.parent
                else
                    if (s.rchild == nil) or (s.rchild.color == __rbtree_color_black) then
                        -- 'BB-1B' : 转换为'BB-1A'
                        s.lchild.color = __rbtree_color_black
                        s.color = __rbtree_color_red
                        __rbtree_rotate_r(this, s)
                        s = p.rchild
                    end
                    -- 'BB-1A' : 调整'p'树平衡（高度不变，无需向上传递）
                    s.color = p.color
                    p.color = __rbtree_color_black
                    if (s.rchild ~= nil) then
                        s.rchild.color = __rbtree_color_black
                    end
                    __rbtree_rotate_l(this, p)
                    break
                end
            else
                local s = p.lchild
                if (s.color == __rbtree_color_red) then
                    -- 'BB-3'转换为'BB-1'
                    -- 'x' = 任意
                    -- 'p' = 黑色
                    -- 's' = 红色
                    s.color = __rbtree_color_black
                    p.color = __rbtree_color_red
                    __rbtree_rotate_r(this, p)
                    s = p.lchild
                end
                if ((s.lchild == nil) or (s.lchild.color == __rbtree_color_black)) and
                   ((s.rchild == nil) or (s.rchild.color == __rbtree_color_black)) then
                    -- 'BB-2' : 调整'p'树平衡（高度降低，需要向上传递）
                    -- 'p' = 任意颜色
                    -- 'x' = 任意颜色
                    -- 's' = 黑色，且两个孩子均不是红色
                    s.color = __rbtree_color_red
                    x = p
                    p = x.parent
                else
                    if (s.lchild == nil) or (s.lchild.color == __rbtree_color_black) then
                        -- 'BB-1B' : 转换为'BB-1A'
                        s.rchild.color = __rbtree_color_black
                        s.color = __rbtree_color_red
                        __rbtree_rotate_l(this, s)
                        s = p.lchild
                    end
                    -- 'BB-1A' : 调整'p'树平衡（高度不变，无需向上传递）
                    s.color = p.color
                    p.color = __rbtree_color_black
                    if (s.lchild ~= nil) then
                        s.lchild.color = __rbtree_color_black
                    end
                    __rbtree_rotate_r(this, p)
                    break
                end
            end
        end
        if (x ~= nil) then
            x.color = __rbtree_color_black
        end
    end
    this.count = this.count - 1
    return y
end

-------------------------------------------------------------------------------
--- 红黑树
local rbtree = newclass("rbtree", require("luamon.container.traits.container"))

function rbtree:xbegin()
    return __rbtree_iterator:new(self, self.header.lchild)
end

function rbtree:xend()
    return __rbtree_iterator:new(self, self.header)
end

function rbtree:rbegin()
    return iterator:rbegin(self)
end

function rbtree:rend()
    return iterator:rend(self)
end

function rbtree:init(kcompare, kextract)
    -- 调整比较逻辑
    if (type(kcompare) ~= "function") then
        kcompare = function(a, b)
            return a < b
        end
    end
    if (type(kextract) ~= "function") then
        kextract = function(a)
            return a
        end
    end
    self.super:init("sequential")
    self.kcompare = kcompare
    self.kextract = kextract
    self.count    = 0
    self.header   = 
    {
        parent = nil,
        value  = nil,
        color  = __rbtree_color_red,
    }
    self.header.lchild = self.header
    self.header.rchild = self.header
end

function rbtree:size()
    return self.count
end

function rbtree:empty()
    return self:size() == 0
end

function rbtree:capacity()
    return 0x7FFFFFFF
end

function rbtree:erase(pos)
    if (pos.class == __rbtree_iterator) and (pos.inst == self) then
        if (pos == self:xend()) then
            return
        else
            __rbtree_erase_aux(self, pos.node)
        end
    else
        error(string.format("'%s[%s]' not match for 'rbtree:erase()'.", tostring(pos), type(pos)))
    end
end

function rbtree:clear()
    self.count = 0
    self.header.parent = nil
    self.header.lchild = self.header
    self.header.rchild = self.header
end

function rbtree:find(k)
    local j = self:lower_bound(k)
    local e = self:xend()
    if (j == e) or (self.kcompare(k, self.kextract(j:get()))) then
        return e
    else
        return j
    end
end

function rbtree:lower_bound(k)
    local x = self.header.parent
    local y = self.header
    while(x ~= nil) do
        if (not self.kcompare(self.kextract(x.value), k)) then
            y = x
            x = x.lchild
        else
            x = x.rchild
        end
    end
    return __rbtree_iterator:new(self, y)
end

function rbtree:upper_bound(k)
    local x = self.header.parent
    local y = self.header
    while(x ~= nil) do
        if self.kcompare(k, self.kextract(x.value)) then
            y = x
            x = x.lchild
        else
            x = x.rchild
        end
    end
    return __rbtree_iterator:new(self, y)
end

function rbtree:equal_range(k)
    return { self:lower_bound(k), self:upper_bound(k) }
end

function rbtree:equal_count(k)
    return algorithm.distance(self:lower_bound(k), self:upper_bound(k))
end

function rbtree:insert_unique(v)
    -- local r = __rbtree_get_insert_unique_pos(self, self.kextract(v))
    -- local e = r[1]
    -- local p = r[2]
    -- if (p ~= nil) then
    --     local z = __rbtree_insert_aux(self, p, v)
    --     return {__rbtree_iterator:new(self, z), true }
    -- else
    --     return {__rbtree_iterator:new(self, e), false}
    -- end
end

function rbtree:insert_equal(v)
    local r = __rbtree_get_insert_equal_pos(self, self.kextract(v))
    return __rbtree_iterator:new(self, __rbtree_insert_aux(self, r[2], v))
end

function rbtree:__len()
    return self:size()
end

function rbtree:__pairs()
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

return rbtree
