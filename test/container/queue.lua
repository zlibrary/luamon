-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Queue     = require 'luamon.container.queue'
local Array     = require 'luamon.container.array'
local Vector    = require 'luamon.container.vector'

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    mytest:assert_not_error(function() Queue:new(nil)                end)
    mytest:assert_not_error(function() Queue:new({})                 end)
    mytest:assert_not_error(function() Queue:new({1, 2})             end)
    mytest:assert_not_error(function() Queue:new(Array:new(20))      end)
    mytest:assert_not_error(function() Queue:new(Vector:new({1, 2})) end)

    mytest:assert_error(function() Queue:new(-1 ) end)
    mytest:assert_error(function() Queue:new(0.1) end)
    mytest:assert_error(function() Queue:new(1.1) end)
    mytest:assert_error(function() Queue:new("" ) end)

    do
        local myqueue = Queue:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        mytest:assert_false(myqueue:empty())
        mytest:assert_eq(myqueue:size(), 10)
    end

    do
        local myqueue = Queue:new({})
        mytest:assert_true(myqueue:empty())
        mytest:assert_eq(myqueue:size(), 0)
    end
end

-- 函数测试
function mytest.testB()

    -- 正常流程
    do
        local myqueue = Queue:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        mytest:assert_eq(myqueue:front(), 1)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 2)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 3)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 4)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 5)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 6)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 7)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 8)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 9)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 0)
        mytest:assert_eq(myqueue:size() , 1)
    end

    -- 数据测试
    do
        local myqueue = Queue:new({1, 2, 3, 4, 5})
        mytest:assert_true (myqueue:size() == 5)
        mytest:assert_false(myqueue:empty())

        myqueue:push(6)
        myqueue:push(7)
        myqueue:push(8)
        myqueue:push(9)
        myqueue:push(0)
        mytest:assert_true (myqueue:size() == 10)
        mytest:assert_false(myqueue:empty())

        mytest:assert_eq(myqueue:front(), 1)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 2)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 3)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 4)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 5)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 6)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 7)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 8)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 9)
        myqueue:pop()
        mytest:assert_eq(myqueue:front(), 0)
        mytest:assert_eq(myqueue:size() , 1)
        myqueue:pop()
        mytest:assert_eq(myqueue:size() , 0)
    end
end

mytest:run()