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
    self.__inst = inst
    self.__node = node
end

function __rbtree_iterator:get()
    return self.__node.value
end

function __rbtree_iterator:set(v)
    self.__node.value = v
end

function __rbtree_iterator:increment()
    if (self.__node == self.__inst.__header) then
        return
    else
        if (self.__node.rchild ~= nil) then
            self.__node = self.__node.rchild
            while(self.__node.lchild) do
                self.__node = self.__obj.lchild
            end
        else
            local p = self.__node.parent
            local x = self.__node
            while(x == p.rchild) do
                x = p
                p = p.parent
            end
            if (x == self.__inst.__header) then
                self.__node = x
            else
                self.__node = p
            end
        end
    end
end

function __rbtree_iterator:decrement()
    if (self.__node == self.__inst.__header) then
        self.__node =  self.__node.rchild
    else
        if (self.__node.lchild ~= nil) then
            self.__node = self.__node.lchild
            while(self.__node.rchild) do
                self.__node = self.__node.rchild
            end
        else
            local p = self.__node.parent
            local x = self.__node
            while(x == p.lchild) do
                x = p
                p = p.parent
            end
            if (x == self.__inst.__header) then
                self.__node = x
            else
                self.__node = p
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
    local tmp = __rbtree_iterator:new(self.__inst, self.__node)
    tmp:decrement()
    return tmp
end

function __rbtree_iterator:next()
    local tmp = __rbtree_iterator:new(self.__inst, self.__node)
    tmp:increment()
    return tmp
end

function __rbtree_iterator:distance(other)
    error("this function is unsupported.")
end

function __rbtree_iterator:__eq(other)
    return (self.class() == other.class()) and (self.__inst == other.__inst) and (self.__node == other.__node)
end

function __rbtree_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local tmp = __rbtree_iterator:new(self.__inst, self.__node)
        tmp:advance(nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __rbtree_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local tmp = __rbtree_iterator:new(self.__inst, self.__node)
        tmp:advance(-nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
local __rbtree_color_red   = 1
local __rbtree_color_black = 2

local function __rbtree_begin(x)
    return x.__header.parent
end

local function __rbtree_end(x)
    return x.__header
end

local function __rbtree_root(x)
    return x.__header.parent
end

local function __rbtree_minimum(x)
    return x.__header.lchild
end

local function __rbtree_maximum(x)
    return x.__header.rchild
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
        if (this.xbegin() == j) then
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
















-------------------------------------------------------------------------------
--- 红黑树
local rbtree = newclass("rbtree", require("luamon.container.traits.container"))

function rbtree:xbegin()
    return __rbtree_iterator:new(self, self.__header.lchild)
end

function rbtree:xend()
    return __rbtree_iterator:new(self, self.__header)
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
    self.__kcompare = kcompare
    self.__kextract = kextract
    self.__count   = 0
    self.__header  = 
    {
        parent = nil,
        value  = nil,
        color  = __rbtree_color_red,
    }
    self.__header.lchild = self.__header
    self.__header.rchild = self.__header
end

function rbtree:size()
    return self.__count
end

function rbtree:empty()
    return self.__count == 0
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

function rbtree:insert_unique(x)
end

function rbtree:insert_equal(x)
end










local __rbtree_node = newclass("__rbtree_node")

function __rbtree_node:init()
    self.__parent = nil
    self.__lchild = nil
    self.__rchild = nil
    self.__color  = nil
    self.__value  = nil
end

