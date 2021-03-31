-------------------------------------------------------------------------------
--- 'luamon.container.map'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local Map       = require 'luamon.container.map'

-- 秩序检查
local function is_sequential(mymap)
    local iter1 = mymap:xbegin()
    local iter2 = iter1 + 1
    while(iter2 ~= mymap:xend()) do
        local v1 = iter1:get()
        local v2 = iter2:get()
        if not mymap.__rbtree.kcompare(v1[1], v2[1]) then
            return false
        end
        iter1 = iter2
        iter2 = iter1 + 1
    end
    return true
end


-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()

    do
        local mymap = Map:new()
        for i = 1, 20 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 20)
        mytest:assert_true(is_sequential(mymap))

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
        mytest:assert_true(is_sequential(mymap))
    end

    do
        local mymap = Map:new()
        for i = 1, 20 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 20)
        mytest:assert_true(is_sequential(mymap))

        for i = 1, 30 do
            mymap:erase(mymap:xbegin())
        end
        mytest:assert_eq(mymap:size(), 0)
        mytest:assert_true(is_sequential(mymap))
    end

end

mytest:run()
