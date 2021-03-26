-------------------------------------------------------------------------------
--- 红黑树， 被设计作为关联容器的底层组件。
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
    error("this function is unsupported.")
end

function __rbtree_iterator:__eq(other)
    return (self.class() == other.class()) and (self.inst == other.inst) and (self.node == other.node)
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

function rbtree:earse(position)
end

function rbtree:clear()
end

function rbtree:find(k)
end

function rbtree:count(k)
end

function rbtree:lower(k)
end

function rbtree:upper(k)
end

function rbtree:range(k)
end

function rbtree:insert_unique(v)
    local r = __rbtree_get_insert_unique_pos(self, self.kextract(v))
    local e = r[1]
    local p = r[2]
    if (p ~= nil) then
        local z = __rbtree_insert_aux(self, p, v)
        return {__rbtree_iterator:new(self, z), true }
    else
        return {__rbtree_iterator:new(self, e), false}
    end
end

function rbtree:insert_equal(v)
    local r = __rbtree_get_insert_equal_pos(self, self.kextract(v))
    return __rbtree_iterator:new(self, __rbtree_insert_aux(self, r[2], v))
end

return rbtree
