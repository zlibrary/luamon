-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Array     = require 'luamon.container.array'

-- 构建测试实例
local mytest = TestSuite.new()

-- 构造测试
function mytest.testA()

    mytest:assert_true(Array:new({})     ~= nil)
    mytest:assert_true(Array:new({1, 2}) ~= nil)
    mytest:assert_true(Array:new(0)      ~= nil)
    mytest:assert_true(Array:new(1)      ~= nil)
    mytest:assert_true(Array:new(100)    ~= nil)

    mytest:assert_error(function() Array:new(nil) end)
    mytest:assert_error(function() Array:new(-1 ) end)
    mytest:assert_error(function() Array:new(0.1) end)
    mytest:assert_error(function() Array:new(1.1) end)
    mytest:assert_error(function() Array:new("" ) end)

    local myarray1 = Array:new({1, 2, 3})
    mytest:assert_false(myarray1:empty())
    mytest:assert_eq(myarray1:size(), 3)
    mytest:assert_eq(myarray1:get(1), 1)
    mytest:assert_eq(myarray1:get(2), 2)
    mytest:assert_eq(myarray1:get(3), 3)

    local myarray2 = Array:new(myarray1)
    mytest:assert_false(myarray2:empty())
    mytest:assert_eq(myarray2:size(), 3)
    mytest:assert_eq(myarray2:get(1), 1)
    mytest:assert_eq(myarray2:get(2), 2)
    mytest:assert_eq(myarray2:get(3), 3)

    local myarray3 = Array:new({})
    mytest:assert_true(myarray3:empty())
    mytest:assert_eq(myarray3:size(), 0)

    local myarray4 = Array:new(myarray3)
    mytest:assert_true(myarray4:empty())
    mytest:assert_eq(myarray4:size(), 0)

    mytest:assert_true (myarray4:is_sequential())
    mytest:assert_false(myarray4:is_associated())

end

-- 迭代测试
function mytest.testB()

    do
        local myarray = Array:new(0)
        local iter1   = myarray:xbegin()
        local iter2   = myarray:xend()
        mytest:assert_eq(iter1, iter2)
        mytest:assert_error(function() return (iter1 - 1) end)
        mytest:assert_error(function() return (iter2 + 1) end)

    end

    do
        local myarray = Array:new(9)
        local iter1   = myarray:xbegin()
        local iter2   = myarray:xend()
        mytest:assert_ne(iter1, iter2)
        for i = 1, 8 do
            iter1:advance(1)
            mytest:assert_ne(iter1, iter2)
        end
        iter1:advance(1)
        mytest:assert_eq(iter1, iter2)
        iter1:advance(-9)
        mytest:assert_eq(iter1, myarray:xbegin())

        -- 赋值/取值
        mytest:assert_not_error(function() iter1:set("") end)
        mytest:assert_not_error(function() iter1:set(10) end)

        mytest:assert_eq(iter1:get(), 10)
        iter1:advance(1)
        mytest:assert_ne(iter1:get(), 10)

        local iter3 = iter1 + 8
        local iter4 = iter2 - 8
        mytest:assert_eq(iter3, iter2)
        mytest:assert_eq(iter4, iter1)
    end

    do
        local myarray = Array:new(0)
        local iter    = myarray:xbegin()
        mytest:assert_true(iter:isa("random-access"))
        mytest:assert_true(iter:isa("input"))
        mytest:assert_true(iter:isa("forward"))
        mytest:assert_true(iter:isa("bidirectional"))
        mytest:assert_false(iter:isa("output"))
    end

end

-- 函数测试
function mytest.testC()

    -- 正常流程
    do
        local myarray = Array:new({1, 2, 3, 4, 5})
        for i = 1, 5 do
            mytest:assert_eq(myarray:get(i), i)
        end
        for i = 1, 5 do
            myarray:set(i, i * 10)
        end
        for i = 1, 5 do
            mytest:assert_eq(myarray:get(i), i * 10)
        end
        mytest:assert_eq(myarray:front(), 10)
        mytest:assert_eq(myarray:back() , 50)
        mytest:assert_eq(#myarray, 5)
        mytest:assert_not_error(function()
            local count = 0
            for i, v in pairs(myarray) do
                count = count + 1
                assert(count == i)
                assert(v == (i*10))
            end
            assert(count == 5)
        end)
        myarray:set(1, nil)
        mytest:assert_not_error(function()
            local count = 0
            for i, v in pairs(myarray) do
                count = count + 1
                assert(count == i)
            end
            assert(count == 5)
        end)
    end

    -- 异常模式
    do
        local myarray = Array:new({1, 2, 3, 4, 5})
        mytest:expect_error(function() myarray:get(0 ) end)
        mytest:expect_error(function() myarray:get(-1) end)
        mytest:expect_error(function() myarray:get(myarray:size() + 1) end)
    end
    do
        local myarray = Array:new({})
        mytest:expect_error(function() myarray:get(0 ) end)
        mytest:expect_error(function() myarray:get(-1) end)
        mytest:expect_error(function() myarray:get(1 ) end)
    end
end

mytest:run()