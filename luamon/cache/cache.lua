-------------------------------------------------------------------------------
--- 仿照 'guava.cache' 实现的数据缓存模块
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local lhm       = require "luamon.container.linked-hashmap"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 模块定义
local cache = newclass("luamon.cache")

function cache:init(params)
end

function cache:capacity()
    return self.cacacity
end

function cache:size()
    return self.lhm:size()
end

function cache:empty()
    return self.lhm:empty()
end

function cache:clear()
end

function cache:evict(key)
end

function cache:get(key, obtain)
end

function cache:put(key, value)
end
