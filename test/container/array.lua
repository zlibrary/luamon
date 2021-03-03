-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Array     = require 'luamon.container.array'

-- 构建测试实例
local mytest = TestSuite.new()

-- 构造测试
function mytest.testA()

    mytest:assert_true(Array:new(0)   ~= nil)
    mytest:assert_true(Array:new(1)   ~= nil)
    mytest:assert_true(Array:new(100) ~= nil)
    
    mytest:assert_error(function() Array:new(nil) end)
    mytest:assert_error(function() Array:new(-1 ) end)
    mytest:assert_error(function() Array:new(0.1) end)
    mytest:assert_error(function() Array:new(1.1) end)
    mytest:assert_error(function() Array:new("" ) end)

end

-- 迭代测试
function mytest.testB()

    do
        local myarray = Array:new(0)
        local iter1   = myarray:front()
        local iter2   = myarray:rear()
        mytest:assert_eq(iter1, iter2)
    end

    do
        local myarray = Array:new(9)
        local iter1   = myarray:front()
        local iter2   = myarray:rear()
        mytest:assert_ne(iter1, iter2)
        for i = 1, 8 do
            iter1:advance(1)
            mytest:assert_ne(iter1, iter2)
        end
        iter1:advance(1)
        mytest:assert_eq(iter1, iter2)
        iter1:advance(-9)
        mytest:assert_eq(iter1, myarray:front())

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

end

-- 函数测试
function mytest.testC()

end

mytest:run()