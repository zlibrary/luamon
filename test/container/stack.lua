-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Stack     = require 'luamon.container.stack'
local Array     = require 'luamon.container.array'
local Vector    = require 'luamon.container.vector'

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    mytest:assert_not_error(function() Stack:new(nil)                end)
    mytest:assert_not_error(function() Stack:new({})                 end)
    mytest:assert_not_error(function() Stack:new({1, 2})             end)
    mytest:assert_not_error(function() Stack:new(Array:new(20))      end)
    mytest:assert_not_error(function() Stack:new(Vector:new({1, 2})) end)

    mytest:assert_error(function() Stack:new(-1 ) end)
    mytest:assert_error(function() Stack:new(0.1) end)
    mytest:assert_error(function() Stack:new(1.1) end)
    mytest:assert_error(function() Stack:new("" ) end)

    do
        local mystack = Stack:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        mytest:assert_false(mystack:empty())
        mytest:assert_eq(mystack:size(), 10)
    end

    do
        local mystack = Stack:new({})
        mytest:assert_true(mystack:empty())
        mytest:assert_eq(mystack:size(), 0)
    end
end

-- 函数测试
function mytest.testB()

    -- 正常流程
    do
        local mystack = Stack:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        mytest:assert_eq(mystack:top(), 0)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 9)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 8)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 7)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 6)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 5)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 4)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 3)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 2)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 1)
        mytest:assert_eq(mystack:size() , 1)
    end

    -- 数据测试
    do
        local mystack = Stack:new({1, 2, 3, 4, 5})
        mytest:assert_true (mystack:size() == 5)
        mytest:assert_false(mystack:empty())

        mystack:push(6)
        mystack:push(7)
        mystack:push(8)
        mystack:push(9)
        mystack:push(0)
        mytest:assert_true (mystack:size() == 10)
        mytest:assert_false(mystack:empty())

        mytest:assert_eq(mystack:top(), 0)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 9)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 8)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 7)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 6)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 5)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 4)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 3)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 2)
        mystack:pop()
        mytest:assert_eq(mystack:top(), 1)
        mystack:pop()
        mytest:assert_eq(mystack:size(), 0)
    end
end

mytest:run()