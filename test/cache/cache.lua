require "luamon"
local testsuite = require 'luamon.ltest'
local algorithm = require "luamon.container.algorithm"
local lhm       = require "luamon.container.linked-hashmap"
local iterator  = require "luamon.container.iterator"
local cache     = require "luamon.cache.cache"
local eraser    = require "luamon.cache.eraser"
local loader    = require "luamon.cache.loader"
local ticker    = require "luamon.cache.ticker"
local evbuilder = require "luamon.cache.evbuilder"

-------------------------------------------------------------------------------
--- 数据加载器
local myloader = newclass("luamon.test.cache.myloader", loader)

function myloader:load(key)
    return key
end

-------------------------------------------------------------------------------
--- 数据移除器
local myeraser = newclass("luamon.test.cache.myeraser", eraser)

function myeraser:exec(key, value)
    print("\nerase :", key, value)
end

-------------------------------------------------------------------------------
local mytest = testsuite.new()

-- 简单测试(复杂多协程测试改到'skynet'框架下进行)
function mytest.testA()

    do
        local params = 
        {
            capacity       = 16,
            loader         = myloader:new(),
            eraser         = myeraser:new(),
            access_expired = 2,
            change_expired = 2,
        }
        local mycache = cache:new(params)
        for i = 1, 20 do
            local v = mycache:get(i)
            mytest:assert_eq(v, i)
        end
        mytest:assert_eq(16, mycache:size())

        mytest:assert_eq(1, mycache:get(1))
        mytest:assert_eq(2, mycache:get(2))
        mytest:assert_eq(8, mycache:get(8))
        mytest:assert_eq(9, mycache:get(9))

        mytest:assert_eq(1, mycache:get(29, function(key) return 1 end))
        mytest:assert_eq(1, mycache:get(29))

        mycache:put(1, 2)
        mytest:assert_eq(2, mycache:get(1))

        mycache:evict(1)
        mytest:assert_eq(15, mycache:size())

        mycache:evict(2)
        mytest:assert_eq(14, mycache:size())

        mycache:evict(3)
        mytest:assert_eq(14, mycache:size())

    end

end

mytest:run()