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

function map:get(k)
    local iter = self.__rbtree:lower_bound(k)
    if (iter == self:xend()) then
        return nil
    else
        return iter:get()[2]
    end
end

function map:set(k, v)
    local iter = self.__rbtree:lower_bound(k)
    if (iter ~= self:xend()) then
        iter:set({k, v})
    else
        self.__rbtree:insert_unique({k, v})
    end
end

function map:insert(k, v)
    return self.__rbtree:insert_unique({k, v})
end

function map:erase(k)
    local i = k
    if (not require("luamon.container.traits.iterator"):made(i)) then
        i = self.__rbtree:find(k)
    end
    self.__rbtree:erase(i)
end

function map:clear()
    self.__rbtree:clear()
end

function map:find(k)
    return self.__rbtree:find(k)
end

function map:count(k)
    return (self.__rbtree:xend() == self.__rbtree:find(k)) and 0 or 1
end

function map:lower_bound(k)
    return self.__rbtree:lower_bound(k)
end

function map:upper_bound(k)
    return self.__rbtree:upper_bound(k)
end

function map:equal_range(k)
    return self.__rbtree:equal_range(k)
end

function rbtree:__len()
    return self:size()
end

function rbtree:__pairs()
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
