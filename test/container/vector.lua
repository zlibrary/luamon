-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Vector    = require 'luamon.container.vector'
local Array     = require 'luamon.container.array'
local Iterator  = require 'luamon.container.iterator'

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    mytest:assert_not_error(function() Vector:new(nil)                end)
    mytest:assert_not_error(function() Vector:new({})                 end)
    mytest:assert_not_error(function() Vector:new({1, 2})             end)
    mytest:assert_not_error(function() Vector:new(Array:new(10))      end)
    mytest:assert_not_error(function() Vector:new(Vector:new({1, 2})) end)

    mytest:assert_error(function() Vector:new(-1 ) end)
    mytest:assert_error(function() Vector:new(0.1) end)
    mytest:assert_error(function() Vector:new(1.1) end)
    mytest:assert_error(function() Vector:new("" ) end)

    do
        local myvector = Vector:new({1, 2, 3})
        mytest:assert_false(myvector:empty())
        mytest:assert_eq(myvector:size(), 3)
        mytest:assert_eq(myvector:get(1), 1)
        mytest:assert_eq(myvector:get(2), 2)
        mytest:assert_eq(myvector:get(3), 3)
    end

    do
        local myvec1 = Vector:new({1, 2, 3})
        local myvec2 = Vector:new(myvec1)
        mytest:assert_false(myvec2:empty())
        mytest:assert_eq(myvec2:size(), 3)
        mytest:assert_eq(myvec2:get(1), 1)
        mytest:assert_eq(myvec2:get(2), 2)
        mytest:assert_eq(myvec2:get(3), 3)
    end

    do
        local myvec1 = Vector:new({})
        local myvec2 = Vector:new(myvec1)
        mytest:assert_true(myvec1:empty())
        mytest:assert_true(myvec2:empty())
        mytest:assert_eq(myvec1:size(), 0)
        mytest:assert_eq(myvec2:size(), 0)
        mytest:assert_true (myvec2:is_sequential())
        mytest:assert_false(myvec2:is_associated())
    end
end

-- 迭代测试
function mytest.testB()

    do
        local myvector = Vector:new(nil)
        local iter1    = myvector:xbegin()
        local iter2    = myvector:xend()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local myvector = Vector:new({})
        local iter1    = myvector:xbegin()
        local iter2    = myvector:xend()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local myvector = Vector:new({1, 2, 3})
        local iter1   = myvector:xbegin()
        local iter2   = myvector:xend()
        mytest:assert_ne(iter1, iter2)
        for i = 1, 2 do
            iter1:advance(1)
            mytest:assert_ne(iter1, iter2)
        end
        iter1:advance(1)
        mytest:assert_eq(iter1, iter2)
        iter1:advance(-3)
        mytest:assert_eq(iter1, myvector:xbegin())

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
        local myvector = Vector:new({})
        local iter     = myvector:xbegin()
        mytest:assert_true (iter:isa("random-access"))
        mytest:assert_true (iter:isa("input"))
        mytest:assert_true (iter:isa("forward"))
        mytest:assert_true (iter:isa("bidirectional"))
        mytest:assert_false(iter:isa("output"))
    end

    do
        local myvector = Vector:new({1, 2, 3, 4, 5})
        local iter1   = myvector:rbegin()
        local iter2   = myvector:rend()
        mytest:assert_eq((iter1 + 0):get(), 5)
        mytest:assert_eq((iter1 + 1):get(), 4)
        mytest:assert_eq((iter1 + 2):get(), 3)
        mytest:assert_eq((iter1 + 3):get(), 2)
        mytest:assert_eq((iter1 + 4):get(), 1)
        mytest:assert_eq((iter1 + 5), iter2  )
    end

end

-- 函数测试
function mytest.testC()

    -- 正常流程
    do
        local myvector = Vector:new({1, 2, 3, 4, 5})
        for i = 1, 5 do
            mytest:assert_eq(myvector:get(i), i)
        end
        for i = 1, 5 do
            myvector:set(i, nil)
        end
        for i = 1, 5 do
            mytest:assert_eq(myvector:get(i), nil)
        end
        for i = 1, 5 do
            myvector:set(i, i * 10)
        end
        for i = 1, 5 do
            mytest:assert_eq(myvector:get(i), i * 10)
        end
        mytest:assert_eq(myvector:front(), 10)
        mytest:assert_eq(myvector:back() , 50)
        mytest:assert_eq(#myvector, 5)
        mytest:assert_not_error(function()
            local count = 0
            for i, v in pairs(myvector) do
                count = count + 1
                assert(count == i)
                assert(v == (i*10))
            end
            assert(count == 5)
        end)
        myvector:set(1, nil)
        mytest:assert_not_error(function()
            local count = 0
            for i, v in pairs(myvector) do
                count = count + 1
                assert(count == i)
            end
            assert(count == 5)
        end)
    end

    -- 异常模式
    do
        local myvector = Vector:new({1, 2, 3, 4, 5})
        mytest:expect_error(function() myvector:set(0 , 1 ) end)
        mytest:expect_error(function() myvector:set(-1, 1) end)
        mytest:expect_error(function() myvector:set(myvector:size() + 1, 1) end)
    end
    do
        local myvector = Vector:new({})
        mytest:expect_error(function() myvector:set(0 , 1 ) end)
        mytest:expect_error(function() myvector:set(-1, 1) end)
        mytest:expect_error(function() myvector:set(myvector:size() + 1, 1) end)
    end

    -- 数据测试
    do
        local myvector = Vector:new(nil)
        mytest:assert_true(myvector:size() == 0)
        mytest:assert_true(myvector:empty())
        mytest:assert_true(myvector:capacity() == 0x7FFFFFFF)

        -- { 1, 1 }
        myvector:resize(2, 1)
        mytest:assert_false(myvector:size() == 0)
        mytest:assert_false(myvector:empty())
        mytest:assert_eq(myvector:size(), 2)
        mytest:assert_eq(myvector:front(), 1)
        mytest:assert_eq(myvector:back(), 1)

        -- {}
        myvector:resize(0, 1)
        mytest:assert_true(myvector:size() == 0)
        mytest:assert_true(myvector:empty())

        -- {1, 2}
        myvector:assign({1, 2})
        mytest:assert_false(myvector:empty())
        mytest:assert_eq(myvector:size(), 2)
        mytest:assert_eq(myvector:front(), 1)
        mytest:assert_eq(myvector:back(), 2)

        -- {1, 2, nil}
        myvector:insert(myvector:xend(), nil)
        mytest:assert_eq(myvector:size(), 3)
        mytest:assert_eq(myvector:front(), 1)
        mytest:assert_eq(myvector:back(), nil)

        -- {2, 1, 2, nil}
        myvector:insert(myvector:xbegin(), 2)
        mytest:assert_eq(myvector:size(), 4)
        mytest:assert_eq(myvector:front(), 2)
        mytest:assert_eq(myvector:back(), nil)

        -- {2, 1, 3, 2, nil}
        myvector:insert(myvector:xbegin() + 2, 3)
        mytest:assert_eq(myvector:size(), 5)
        mytest:assert_eq(myvector:front(), 2)
        mytest:assert_eq(myvector:back(), nil)
        mytest:assert_eq(myvector:get(2), 1)

        -- {2, 1, 3, 2, nil, 1}
        myvector:push_back(1)
        mytest:assert_eq(myvector:size(), 6)
        mytest:assert_eq(myvector:front(), 2)
        mytest:assert_eq(myvector:back(), 1)
        mytest:assert_eq(myvector:get(2), 1)

        -- {2, 1, 3, 2, nil}
        myvector:pop_back()
        mytest:assert_eq(myvector:size(), 5)
        mytest:assert_eq(myvector:front(), 2)
        mytest:assert_eq(myvector:back(), nil)
        mytest:assert_eq(myvector:get(2), 1)

        -- {2, 1, 3, 2, nil}
        myvector:erase(myvector:xend())
        mytest:assert_eq(myvector:size(), 5)
        mytest:assert_eq(myvector:front(), 2)
        mytest:assert_eq(myvector:back(), nil)
        mytest:assert_eq(myvector:get(2), 1)

        -- {2, 1, 3, 2}
        myvector:erase(myvector:xend() - 1)
        mytest:assert_eq(myvector:size(), 4)
        mytest:assert_eq(myvector:front(), 2)
        mytest:assert_eq(myvector:back(), 2)
        mytest:assert_eq(myvector:get(2), 1)

        -- {1, 3, 2}
        myvector:erase(myvector:xbegin())
        mytest:assert_eq(myvector:size(), 3)
        mytest:assert_eq(myvector:front(), 1)
        mytest:assert_eq(myvector:back(), 2)
        mytest:assert_eq(myvector:get(2), 3)

    end
end

-- 其他测试
function mytest.testD()

    do
        local myvector = Vector:new({1, 2, 3, 4, 5})
        myvector:set(2, nil)
        myvector:set(4, nil)
        mytest:assert_eq(myvector:size(), 5)
        mytest:assert_eq(myvector:get(1), 1)
        mytest:assert_eq(myvector:get(2), nil)
        mytest:assert_eq(myvector:get(3), 3)
        mytest:assert_eq(myvector:get(4), nil)
        mytest:assert_eq(myvector:get(5), 5)
    end

end

mytest:run()