-------------------------------------------------------------------------------
--- 'luamon.container.map'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Map       = require 'luamon.container.linked-hashmap'

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    -- 使用插入顺序
    do
        local mymap = Map:new()
        for i = 1, 20 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 20)

        mymap:set(1, 3)
        mymap:set(5, 3)
        mymap:set(7, 3)

        local iter = mymap:xbegin()
        mytest:assert_eq(iter:get()[1], 1)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 2)
        mytest:assert_eq(iter:get()[2], 2)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 3)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 4)
        mytest:assert_eq(iter:get()[2], 4)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 5)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 6)
        mytest:assert_eq(iter:get()[2], 6)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 7)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 8)
        mytest:assert_eq(iter:get()[2], 8)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 9)
        mytest:assert_eq(iter:get()[2], 9)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 10)
        mytest:assert_eq(iter:get()[2], 10)

        mymap:clear()
        mytest:assert_eq(mymap:size(), 0)
    end

    -- 使用访问顺序
    do
        local mymap = Map:new('access-order')
        for i = 1, 20 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 20)

        mymap:set(1, 3)
        mymap:set(5, 3)
        mymap:set(7, 3)

        local iter = mymap:xbegin()
        mytest:assert_eq(iter:get()[1], 2)
        mytest:assert_eq(iter:get()[2], 2)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 3)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 4)
        mytest:assert_eq(iter:get()[2], 4)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 6)
        mytest:assert_eq(iter:get()[2], 6)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 8)
        mytest:assert_eq(iter:get()[2], 8)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 9)
        mytest:assert_eq(iter:get()[2], 9)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 10)
        mytest:assert_eq(iter:get()[2], 10)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 11)
        mytest:assert_eq(iter:get()[2], 11)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 12)
        mytest:assert_eq(iter:get()[2], 12)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 13)
        mytest:assert_eq(iter:get()[2], 13)

        local iter = mymap:rbegin()
        mytest:assert_eq(iter:get()[1], 7)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 5)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 1)
        mytest:assert_eq(iter:get()[2], 3)

        mymap:get(12)
        mytest:assert_eq(mymap:rbegin():get()[1], 12)
        mytest:assert_eq(mymap:rbegin():get()[2], 12)

        mymap:erase(mymap:xbegin())
        mymap:erase(4)
        mymap:erase(4)
        mymap:erase(6)
        mymap:erase(7)
        mymap:erase(mymap:xbegin())
        mytest:assert_eq(mymap:size(), 15)

        local iter = mymap:xbegin()
        mytest:assert_eq(iter:get()[1], 8)
        mytest:assert_eq(iter:get()[2], 8)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 9)
        mytest:assert_eq(iter:get()[2], 9)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 10)
        mytest:assert_eq(iter:get()[2], 10)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 11)
        mytest:assert_eq(iter:get()[2], 11)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 13)
        mytest:assert_eq(iter:get()[2], 13)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 14)
        mytest:assert_eq(iter:get()[2], 14)

        local iter = mymap:rbegin()
        mytest:assert_eq(iter:get()[1], 12)
        mytest:assert_eq(iter:get()[2], 12)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 5)
        mytest:assert_eq(iter:get()[2], 3)
        iter:advance(1)
        mytest:assert_eq(iter:get()[1], 1)
        mytest:assert_eq(iter:get()[2], 3)

        mymap:clear()
        mytest:assert_eq(mymap:size(), 0)
    end
end

function mytest.testB()
    do
        local mymap = Map:new()
        local mytab = {}
        for i = 1, 1000000 do
            mymap:insert(i, i)
        end
    end
end

mytest:run()
