-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Vector    = require 'luamon.container.vector'
local Array     = require 'luamon.container.array'
local List      = require 'luamon.container.list'
local Iterator  = require 'luamon.container.iterator'

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    mytest:assert_not_error(function() List:new(nil)                end)
    mytest:assert_not_error(function() List:new({})                 end)
    mytest:assert_not_error(function() List:new({1, 2})             end)
    mytest:assert_not_error(function() List:new(Array:new(10))      end)
    mytest:assert_not_error(function() List:new(Vector:new({1, 2})) end)

    mytest:assert_error(function() List:new(-1 ) end)
    mytest:assert_error(function() List:new(0.1) end)
    mytest:assert_error(function() List:new(1.1) end)
    mytest:assert_error(function() List:new("" ) end)

    do
        local mylist = List:new({1, 2, 3})
        mytest:assert_false(mylist:empty())
        mytest:assert_eq(mylist:size(), 3)
    end

    do
        local mylist1 = List:new({1, 2, 3})
        local mylist2 = List:new(mylist1)
        mytest:assert_false(mylist2:empty())
        mytest:assert_eq(mylist2:size(), 3)
    end

    do
        local mylist1 = List:new({})
        local mylist2 = List:new(mylist1)
        mytest:assert_true(mylist1:empty())
        mytest:assert_true(mylist2:empty())
        mytest:assert_eq(mylist1:size(), 0)
        mytest:assert_eq(mylist2:size(), 0)
        mytest:assert_true (mylist2:is_sequential())
        mytest:assert_false(mylist2:is_associated())
    end
end

-- 迭代测试
function mytest.testB()

    do
        local mylist = List:new(nil)
        local iter1  = mylist:xbegin()
        local iter2  = mylist:xend()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local mylist = List:new({})
        local iter1  = mylist:xbegin()
        local iter2  = mylist:xend()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local mylist = List:new({1, 2, 3})
        local iter1   = mylist:xbegin()
        local iter2   = mylist:xend()
        mytest:assert_ne(iter1, iter2)
        for i = 1, 2 do
            iter1:advance(1)
            mytest:assert_ne(iter1, iter2)
        end
        iter1:advance(1)
        mytest:assert_eq(iter1, iter2)
        iter1:advance(-3)
        mytest:assert_eq(iter1, mylist:xbegin())

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
        local mylist = List:new({})
        local iter   = mylist:xbegin()
        mytest:assert_false(iter:isa("random-access"))
        mytest:assert_true (iter:isa("input"))
        mytest:assert_true (iter:isa("forward"))
        mytest:assert_true (iter:isa("bidirectional"))
        mytest:assert_false(iter:isa("output"))
    end

    do
        local mylist = List:new({1, 2, 3, 4, 5})
        local iter1  = mylist:rbegin()
        local iter2  = mylist:rend()
        mytest:assert_eq((iter1 + 0):get(), 5)
        mytest:assert_eq((iter1 + 1):get(), 4)
        mytest:assert_eq((iter1 + 2):get(), 3)
        mytest:assert_eq((iter1 + 3):get(), 2)
        mytest:assert_eq((iter1 + 4):get(), 1)
        mytest:assert_eq((iter1 + 5), iter2  )
    end

    do
        local mylist = List:new({})
        local iter1  = mylist:xbegin()
        local iter2  = mylist:xend()
        mytest:assert_eq(iter1:distance(iter2), 0)
        mytest:assert_eq(iter2:distance(iter1), 0)
    end

    do
        local mylist = List:new({1, 2, 3, 4, 5})
        local iter1  = mylist:xbegin()
        local iter2  = mylist:xend()
        mytest:assert_eq(iter1:distance(iter2), 5)
        mytest:assert_eq(iter2:distance(iter1), 1)
        iter1:advance(1)
        mytest:assert_eq(iter1:distance(iter2), 4)
        mytest:assert_eq(iter2:distance(iter1), 2)
        iter2:advance(-1)
        mytest:assert_eq(iter1:distance(iter2), 3)
        mytest:assert_eq(iter2:distance(iter1), 3)
    end

    do
        local mylist = List:new({1, 2, 3, 4, 5})
        local iter1  = mylist:rbegin()
        local iter2  = mylist:rend()
        mytest:assert_eq(iter1:distance(iter2), 5)
        mytest:assert_eq(iter2:distance(iter1), 1)
        iter1:advance(1)
        mytest:assert_eq(iter1:distance(iter2), 4)
        mytest:assert_eq(iter2:distance(iter1), 2)
        iter2:advance(-1)
        mytest:assert_eq(iter1:distance(iter2), 3)
        mytest:assert_eq(iter2:distance(iter1), 3)
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
        local mylist = List:new(nil)
        mytest:assert_true(mylist:size() == 0)
        mytest:assert_true(mylist:empty())
        mytest:assert_true(mylist:capacity() == 0x7FFFFFFF)

        -- { 1, 1 }
        mylist:resize(2, 1)
        mytest:assert_false(mylist:size() == 0)
        mytest:assert_false(mylist:empty())
        mytest:assert_eq(mylist:size(), 2)
        mytest:assert_eq(mylist:front(), 1)
        mytest:assert_eq(mylist:back(), 1)

        -- {}
        mylist:resize(0, 1)
        mytest:assert_true(mylist:size() == 0)
        mytest:assert_true(mylist:empty())

        -- {1, 2}
        mylist:assign({1, 2})
        mytest:assert_false(mylist:empty())
        mytest:assert_eq(mylist:size(), 2)
        mytest:assert_eq(mylist:front(), 1)
        mytest:assert_eq(mylist:back(), 2)

        -- {1, 2, nil}
        mylist:insert(mylist:xend(), nil)
        mytest:assert_eq(mylist:size(), 3)
        mytest:assert_eq(mylist:front(), 1)
        mytest:assert_eq(mylist:back(), nil)

        -- {2, 1, 2, nil}
        mylist:insert(mylist:xbegin(), 2)
        mytest:assert_eq(mylist:size(), 4)
        mytest:assert_eq(mylist:front(), 2)
        mytest:assert_eq(mylist:back(), nil)

        -- {2, 1, 3, 2, nil}
        mylist:insert(mylist:xbegin() + 2, 3)
        mytest:assert_eq(mylist:size(), 5)
        mytest:assert_eq(mylist:front(), 2)
        mytest:assert_eq(mylist:back(), nil)

        -- {2, 1, 3, 2, nil, 1}
        mylist:push_back(1)
        mytest:assert_eq(mylist:size(), 6)
        mytest:assert_eq(mylist:front(), 2)
        mytest:assert_eq(mylist:back(), 1)

        -- {2, 1, 3, 2, nil}
        mylist:pop_back()
        mytest:assert_eq(mylist:size(), 5)
        mytest:assert_eq(mylist:front(), 2)
        mytest:assert_eq(mylist:back(), nil)

        -- {2, 1, 3, 2, nil}
        mylist:erase(mylist:xend())
        mytest:assert_eq(mylist:size(), 5)
        mytest:assert_eq(mylist:front(), 2)
        mytest:assert_eq(mylist:back(), nil)

        -- {2, 1, 3, 2}
        mylist:erase(mylist:xend() - 1)
        mytest:assert_eq(mylist:size(), 4)
        mytest:assert_eq(mylist:front(), 2)
        mytest:assert_eq(mylist:back(), 2)

        -- {1, 3, 2}
        mylist:erase(mylist:xbegin())
        mytest:assert_eq(mylist:size(), 3)
        mytest:assert_eq(mylist:front(), 1)
        mytest:assert_eq(mylist:back(), 2)

        -- {nil, 1, 3, 2}
        mylist:push_front(nil)
        mytest:assert_eq(mylist:size(), 4)
        mytest:assert_eq(mylist:front(), nil)
        mytest:assert_eq(mylist:back(), 2)

        -- {1, 3, 2}
        mylist:pop_front()
        mytest:assert_eq(mylist:size(), 3)
        mytest:assert_eq(mylist:front(), 1)
        mytest:assert_eq(mylist:back(), 2)

        -- {}
        mylist:clear()
        mytest:assert_eq(mylist:size(), 0)

    end
end

mytest:run()