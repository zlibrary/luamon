-------------------------------------------------------------------------------
--- 针对'luamon.ltest'的基础测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'

local function f1()
    error('throw an exception.')
end

local function f2()
    return 0
end

-- 构建测试实例
local mytest = TestSuite.new()

function mytest.testA()
    local s1 = 'ABC'
    local s2 = 'abc'
    local v1 = 1
    local v2 = 2
    local t1 = {}
    local t2 = {}
    -- 数值比较
    mytest:expect_eq(s1, s1)
    mytest:expect_ne(s1, s2)
    mytest:expect_eq(t1, t1)
    mytest:expect_ne(t1, t2)
    mytest:expect_eq(v1, v1)
    mytest:expect_ne(v1, v2)
    mytest:expect_lt(v1, v2)
    mytest:expect_gt(v2, v1)
    mytest:expect_le(v1, v1)
    mytest:expect_le(v1, v2)
    mytest:expect_ge(v2, v1)
    mytest:expect_ge(v2, v2)
    -- 条件判断
    mytest:expect_true (nil  )
    mytest:expect_true (true )
    mytest:expect_false(false)
    -- 异常检查
    mytest:expect_error(f1)
    mytest:expect_not_error(f2)
end

mytest:run()
