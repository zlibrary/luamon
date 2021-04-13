-------------------------------------------------------------------------------
--- 关联容器。在哈希表的基础上增加了双向链表，使其具有可预测的迭代顺序。
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __lhm_iterator = newclass("__lhm_iterator", require("luamon.container.traits.iterator"))

function __lhm_iterator:init(obj, node)
    self.super:init("bidirectional")
    self.__obj  = obj
    self.__node = node
end

function __lhm_iterator:get()
    return self.__node[3]
end

function __lhm_iterator:set(v)
    self.__node[3] = v
end

function __lhm_iterator:advance(n)
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

function __lhm_iterator:prev()
    return __lhm_iterator:new(self.__obj, self.__node[1])
end

function __lhm_iterator:next()
    return __lhm_iterator:new(self.__obj, self.__node[2])
end

function __lhm_iterator:distance(other)
    if (other.class == __lhm_iterator) and (self.__obj == other.__obj) then
        local c = self
        local n = 0
        while(c ~= other) do
            n = n + 1
            c = c + 1
        end
        return n
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function __lhm_iterator:__eq(other)
    return (other.class == __lhm_iterator) and (self.__obj == other.__obj) and (self.__node == other.__node)
end

function __lhm_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __lhm_iterator:new(self.__obj, self.__node)
        iter:advance(nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __lhm_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __lhm_iterator:new(self.__obj, self.__node)
        iter:advance(-nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 链表定义（简化的'list'容器）
local __lhm_list = newclass("__lhm_list")

-- 插入节点
local function __list_insert_aux(this, p, v)
    this.__size = this.__size + 1
    local node = 
    {
        [1] = p[1],
        [2] = p,
        [3] = v,
    }
    p[1][2] = node
    p[1]    = node
    return node
end

-- 移除节点
local function __list_erase_aux(this, p)
    if (p == this.__node) then
        return p
    else
        p[1][2] = p[2]
        p[2][1] = p[1]
        this.__size = this.__size - 1
        return p[2]
    end
end

function __lhm_list:init()
    self.__node = {}
    self.__size = 0
    self.__node[1] = self.__node
    self.__node[2] = self.__node
end

function __lhm_list:capacity()
    return 0x7FFFFFFF
end

function __lhm_list:size()
    return self.__size
end

function __lhm_list:empty()
    return (self.__size == 0)
end

function __lhm_list:clear()
    self.__node = {}
    self.__size = 0
    self.__node[1] = self.__node
    self.__node[2] = self.__node
end

function __lhm_list:erase(p)
    return __list_erase_aux(self, p)
end

function __lhm_list:push_back(v)
    return __list_insert_aux(self, self.__node, v)
end

-------------------------------------------------------------------------------
--- 容器定义
local map = newclass("linked-hashmap", require("luamon.container.traits.container"))

function map:xbegin()
    return __lhm_iterator:new(self.__linked, self.__linked.__node[2])
end

function map:xend()
    return __lhm_iterator:new(self.__linked, self.__linked.__node)
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
    self.__linked  = __lhm_list:new()
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
        local v = node[3]
        if (self.__mutable == true) then
            self.__linked:erase(node)
            self.__linked:push_back(v)
        end
        return v[2]
    end
end

function map:set(k, v)
    local node = self.__htable[k]
    if ((node ~= nil) and (self.__mutable == false)) then
        node[3] = {k,v}
    else
        if (node ~= nil) then
            self.__linked:erase(node)
        end
        self.__htable[k] = self.__linked:push_back({k,v})
    end
end

function map:insert(k, v)
    local node = self.__htable[k]
    if (node == nil) then
        self.__htable[k] = self.__linked:push_back({k,v})
        return true
    else
        return false
    end
end

function map:erase(k)
    if __lhm_iterator:made(k) and (self.__linked == k.__obj) then
        k = k:get()[1]
    end
    local node = self.__htable[k]
    if (node ~= nil) then
        self.__htable[k] = nil
        self.__linked:erase(node)
    end
end

function map:clear()
    self.__htable  = {}
    self.__linked  = __lhm_list:new()
end

function map:find(k)
    local node = self.__htable[k]
    if (node == nil) then
        return self:xend()
    else
        return __lhm_iterator:new(self.__linked, node)
    end
end

function map:count(k)
    if (self:xend() == self:find(k)) then
        return 0
    else
        return 1
    end
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
