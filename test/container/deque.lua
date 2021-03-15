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
        mytest:assert_true (iter:isa("random-access"))
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
        mytest:assert_eq((iter1 +10), iter2  )
    end

    do
        local mydeque = Deque:new({})
        local iter1   = mydeque:xbegin()
        local iter2   = mydeque:xend()
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


-- 函数测试
function mytest.testC()

    -- 正常流程
    do
        local mylist = List:new({1, 2, 3, 4, 5})
        local iter   = mylist:xbegin()
        mytest:assert_eq((iter + 0):get(), 1)
        mytest:assert_eq((iter + 1):get(), 2)
        mytest:assert_eq((iter + 2):get(), 3)
        mytest:assert_eq((iter + 3):get(), 4)
        mytest:assert_eq((iter + 4):get(), 5)
        mytest:assert_eq(mylist:front(), 1)
        mytest:assert_eq(mylist:back() , 5)
        mytest:assert_eq(#mylist, 5)
        mytest:assert_not_error(function()
            local count = 0
            for i, v in pairs(mylist) do
                count = count + 1
                assert(count == i)
                assert(v == i)
            end
            assert(count == 5)
        end)
    end

    -- 数据测试
    do
        local mydeque = Deque:new(nil)
        mytest:assert_true(mydeque:size() == 0)
        mytest:assert_true(mydeque:empty())
        mytest:assert_true(mydeque:capacity() == 0x7FFFFFFF)

        -- { 1, 1 }
        mydeque:resize(20, 1)
        mytest:assert_false(mydeque:size() == 0)
        mytest:assert_false(mydeque:empty())
        mytest:assert_eq(mydeque:size(), 20)
        mytest:assert_eq(mydeque:front(), 1)
        mytest:assert_eq(mydeque:back(), 1)

        -- {}
        mydeque:resize(0, 1)
        mytest:assert_true(mydeque:size() == 0)
        mytest:assert_true(mydeque:empty())

        -- {1, 2}
        mydeque:assign({1, 2})
        mytest:assert_false(mydeque:empty())
        mytest:assert_eq(mydeque:size(), 2)
        mytest:assert_eq(mydeque:front(), 1)
        mytest:assert_eq(mydeque:back(), 2)

        -- {1, 2, nil}
        mydeque:insert(mydeque:xend(), nil)
        mytest:assert_eq(mydeque:size(), 3)
        mytest:assert_eq(mydeque:front(), 1)
        mytest:assert_eq(mydeque:back(), nil)

        -- {2, 1, 2, nil}
        mydeque:insert(mydeque:xbegin(), 2)
        mytest:assert_eq(mydeque:size(), 4)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), nil)

        -- {2, 1, 3, 2, nil}
        mydeque:insert(mydeque:xbegin() + 2, 3)
        mytest:assert_eq(mydeque:size(), 5)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), nil)

        -- {2, 1, 3, 2, nil, 1}
        mydeque:push_back(1)
        mytest:assert_eq(mydeque:size(), 6)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), 1)

        -- {2, 1, 3, 2, nil}
        mydeque:pop_back()
        mytest:assert_eq(mydeque:size(), 5)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), nil)

        -- {7, 2, 1, 3, 2, nil}
        mydeque:push_front(7)
        mytest:assert_eq(mydeque:size(), 6)
        mytest:assert_eq(mydeque:front(), 7)
        mytest:assert_eq(mydeque:back(), nil)

        -- {2, 1, 3, 2, nil}
        mydeque:pop_front()
        mytest:assert_eq(mydeque:size(), 5)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), nil)

        -- {2, 1, 3, 2, nil}
        mydeque:erase(mydeque:xend())
        mytest:assert_eq(mydeque:size(), 5)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), nil)

        -- {2, 1, 3, 2}
        mydeque:erase(mydeque:xend() - 1)
        mytest:assert_eq(mydeque:size(), 4)
        mytest:assert_eq(mydeque:front(), 2)
        mytest:assert_eq(mydeque:back(), 2)

        -- {1, 3, 2}
        mydeque:erase(mydeque:xbegin())
        mytest:assert_eq(mydeque:size(), 3)
        mytest:assert_eq(mydeque:front(), 1)
        mytest:assert_eq(mydeque:back(), 2)

        -- {nil, 1, 3, 2}
        mydeque:push_front(nil)
        mytest:assert_eq(mydeque:size(), 4)
        mytest:assert_eq(mydeque:front(), nil)
        mytest:assert_eq(mydeque:back(), 2)

        -- {1, 3, 2}
        mydeque:pop_front()
        mytest:assert_eq(mydeque:size(), 3)
        mytest:assert_eq(mydeque:front(), 1)
        mytest:assert_eq(mydeque:back(), 2)

        -- {6, 5, 4, 3, 2, 1, 1, 3, 2}
        mydeque:push_front(1)
        mydeque:push_front(2)
        mydeque:push_front(3)
        mydeque:push_front(4)
        mydeque:push_front(5)
        mydeque:push_front(6)
        mytest:assert_eq(mydeque:get(1), 6)
        mytest:assert_eq(mydeque:get(2), 5)
        mytest:assert_eq(mydeque:get(3), 4)
        mytest:assert_eq(mydeque:get(4), 3)
        mytest:assert_eq(mydeque:get(5), 2)
        mytest:assert_eq(mydeque:get(6), 1)
        mytest:assert_eq(mydeque:get(7), 1)

        -- {6, 5, 4, 3, 2, 1, 1, 3, 2, 1, 2, 3, 4, 5 ,6}
        mydeque:push_back(1)
        mydeque:push_back(2)
        mydeque:push_back(3)
        mydeque:push_back(4)
        mydeque:push_back(5)
        mydeque:push_back(6)
        mytest:assert_eq(mydeque:get(10), 1)
        mytest:assert_eq(mydeque:get(11), 2)
        mytest:assert_eq(mydeque:get(12), 3)
        mytest:assert_eq(mydeque:get(13), 4)
        mytest:assert_eq(mydeque:get(14), 5)
        mytest:assert_eq(mydeque:get(15), 6)

        -- {}
        mydeque:clear()
        mytest:assert_eq(mydeque:size(), 0)

    end
end

mytest:run()
