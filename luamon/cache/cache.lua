-------------------------------------------------------------------------------
--- 仿照 'guava.cache' 实现的数据缓存模块
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local lhm       = require "luamon.container.linked-hashmap"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
--- 模块定义
local cache = newclass("cache")




