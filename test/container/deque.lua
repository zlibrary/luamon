-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Vector    = require 'luamon.container.vector'
local Array     = require 'luamon.container.array'
local List      = require 'luamon.container.list'
local Deque     = require 'luamon.container.deque'
local Iterator  = require 'luamon.container.iterator'

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    mytest:assert_not_error(function() Deque:new(nil)                end)
    mytest:assert_not_error(function() Deque:new({})                 end)
    mytest:assert_not_error(function() Deque:new({1, 2})             end)
    mytest:assert_not_error(function() Deque:new(Array:new(20))      end)
    mytest:assert_not_error(function() Deque:new(Vector:new({1, 2})) end)

    mytest:assert_error(function() Deque:new(-1 ) end)
    mytest:assert_error(function() Deque:new(0.1) end)
    mytest:assert_error(function() Deque:new(1.1) end)
    mytest:assert_error(function() Deque:new("" ) end)

    do
        local mydeque = Deque:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        mytest:assert_false(mydeque:empty())
        mytest:assert_eq(mydeque:size(), 10)
    end

    do
        local mydeque1 = Deque:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        local mydeque2 = Deque:new(mydeque1)
        mytest:assert_false(mydeque2:empty())
        mytest:assert_eq(mydeque2:size(), 10)
    end

    do
        local mydeque1 = Deque:new({})
        local mydeque2 = Deque:new(mydeque1)
        mytest:assert_true(mydeque1:empty())
        mytest:assert_true(mydeque2:empty())
        mytest:assert_eq(mydeque1:size(), 0)
        mytest:assert_eq(mydeque2:size(), 0)
        mytest:assert_true (mydeque2:is_sequential())
        mytest:assert_false(mydeque2:is_associated())
    end
end

-- 迭代测试
function mytest.testB()

    do
        local mydeque = Deque:new(nil)
        local iter1   = mydeque:xbegin()
        local iter2   = mydeque:xend()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local mydeque = Deque:new({})
        local iter1   = mydeque:xbegin()
        local iter2   = mydeque:xend()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local mydeque = Deque:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        local iter1   = mydeque:xbegin()
        local iter2   = mydeque:xend()
        mytest:assert_ne(iter1, iter2)
        for i = 1, 9 do
            iter1:advance(1)
            mytest:assert_ne(iter1, iter2)
        end
        iter1:advance(1)
        mytest:assert_eq(iter1, iter2)
        iter1:advance(-10)
        mytest:assert_eq(iter1, mydeque:xbegin())

        -- 赋值/取值
        mytest:assert_not_error(function() iter1:set("") end)
        mytest:assert_not_error(function() iter1:set(10) end)
        mytest:assert_eq(iter1:get(), 10)
        iter1:advance(1)
        mytest:assert_ne(iter1:get(), 10)
        iter1:set(nil)
        mytest:assert_eq(iter1:get(), nil)
    end

    do
        local mydeque = Deque:new({})
        local iter   = mydeque:xbegin()
        mytest:assert_false(iter:isa("random-access"))
        mytest:assert_true (iter:isa("input"))
        mytest:assert_true (iter:isa("forward"))
        mytest:assert_true (iter:isa("bidirectional"))
        mytest:assert_false(iter:isa("output"))
    end

    do
        local mydeque = Deque:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        local iter1   = mydeque:rbegin()
        local iter2   = mydeque:rend()
        mytest:assert_eq((iter1 + 0):get(), 0)
        mytest:assert_eq((iter1 + 1):get(), 9)
        mytest:assert_eq((iter1 + 2):get(), 8)
        mytest:assert_eq((iter1 + 3):get(), 7)
        mytest:assert_eq((iter1 + 4):get(), 6)
        mytest:assert_eq((iter1 + 5):get(), 5)
        mytest:assert_eq((iter1 + 6):get(), 4)
        mytest:assert_eq((iter1 + 7):get(), 3)
        mytest:assert_eq((iter1 + 8):get(), 2)
        mytest:assert_eq((iter1 + 9):get(), 1)
        mytest:assert_eq((iter1 + 1), iter2  )
    end

    do
        local mydeque = Deque:new({})
        local iter1   = mylist:xbegin()
        local iter2   = mylist:xend()
        mytest:assert_eq(iter1:distance(iter2), 0)
        mytest:assert_eq(iter2:distance(iter1), 0)
    end

    do
        local mydeque = Deque:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 0})
        local iter1   = mydeque:rbegin()
        local iter2   = mydeque:rend()
        mytest:assert_eq(iter1:distance(iter2),  10)
        mytest:assert_eq(iter2:distance(iter1), -10)
        iter1:advance(1)
        mytest:assert_eq(iter1:distance(iter2),  9)
        mytest:assert_eq(iter2:distance(iter1), -9)
        iter2:advance(-1)
        mytest:assert_eq(iter1:distance(iter2),  8)
        mytest:assert_eq(iter2:distance(iter1), -8)
    end
end

mytest:run()
