-------------------------------------------------------------------------------
--- 关联容器，用于存储由键值和映射值组合而成的元素。
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local rbtree    = require "luamon.container.rbtree"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 容器定义
local map = newclass("map", require("luamon.container.traits.container"))

function map:xbegin()
    return self.__rbtree:xbegin()
end

function map:xend()
    return self.__rbtree:xend()
end

function map:rbegin()
    return iterator:rbegin(self)
end

function map:rend()
    return iterator:rend(self)
end

function map:init(compare)
    -- 调整比较逻辑
    if (compare == nil) then
        compare = function(a, b)
            return a < b
        end
    end
    assert(type(compare) == "function", string.format("'%s[%s]' must be a 'function'.", tostring(compare), type(compare)))
    self.super:init("associated")
    self.__rbtree = rbtree:new(compare, function(v) return v[1] end)
end

function map:size()
    return self.__rbtree:size()
end

function map:empty()
    return self.__rbtree:empty()
end

function map:capacity()
    return self.__rbtree:capacity()
end

function map:get(key)
    local iter = self.__rbtree:lower_bound(key)
    if (iter ~= self:xend()) then
        return iter:get()[2]
    else
        error("out of range.")
    end
end

function map:set(key, value)
    local iter = self.__rbtree:lower_bound(key)
    if (iter ~= self:xend()) then
        iter:set({key, value}) -- 覆盖
    else
        self.__rbtree:insert_unique({key, value})
    end
end

function map:insert(key, value)
    return self.__rbtree:insert_unique({key, value})
end



