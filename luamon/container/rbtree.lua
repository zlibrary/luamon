-------------------------------------------------------------------------------
--- 红黑树， 被设计作为关联容器的底层组件。
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __rbtree_iterator = newclass("__rbtree_iterator", require("luamon.container.traits.iterator"))

function __rbtree_iterator:init(obj, node)
    self.super:init("bidirectional")
    self.__obj  = obj
    self.__node = node
end

function __rbtree_iterator:get()
    return self.__value
end

function __rbtree_iterator:set(v)
    self.__value = v
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
                self.__node = self.__node.__lchild
            else
                nm = nm - 1
                self.__node = self.__node.__rchild
            end
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __rbtree_iterator:prev()
    return __rbtree_iterator:new(self.__obj, self.__node.__lchild)
end

function __rbtree_iterator:next()
    return __rbtree_iterator:new(self.__obj, self.__node.__rchild)
end

function __rbtree_iterator:__eq(other)
    return (self.class() == other.class()) and (self.__obj == other.__obj) and (self.__node == other.__node)
end

function __rbtree_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __rbtree_iterator:new(self.__obj, self.__node)
        iter:advance(nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __rbtree_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __rbtree_iterator:new(self.__obj, self.__node)
        iter:advance(-nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 红黑树













local __rbtree_node = newclass("__rbtree_node")

function __rbtree_node:init()
    self.__parent = nil
    self.__lchild = nil
    self.__rchild = nil
    self.__color  = nil
    self.__value  = nil
end

