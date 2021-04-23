-------------------------------------------------------------------------------
--- 'luamon.container.zmap'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local zmap      = require 'luamon.container.zmap'

-- 秩序检查
local function is_sequential(mymap)
    local iter1 = mymap:xbegin()
    local iter2 = iter1 + 1
    local iter3 = mymap:xend()
    while(iter2 ~= iter3) do
        local v1 = iter1:get()
        local v2 = iter2:get()
        if mymap.__linked.kcompare(v2[2], v1[2]) then
            return false
        end
        iter1:advance(1)
        iter2:advance(1)
    end
    return true
end

local function zprint(mymap)
    local function vprint(node)
        print("----", node, (node.value or {})[1], (node.value or {})[2])
        for i = 1, mymap.__linked.__level do
            local link = node.links[i]
            if (link == nil) then
                break
            else
                print("--------", link.span, link.prev, link.next)
            end
        end
    end
    local x = mymap.__linked.__header
    local e = mymap.__linked.__header
    while(true) do
        vprint(x)
        x = x.links[1].next
        if (x == e) then
            break
        end
    end
end

-- 构建测试实例
local mytest = TestSuite.new()

-- 基本测试
function mytest.testA()
    do
        local mymap = zmap:new()
        for i = 1, 20 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 20)
        mytest:assert_true(is_sequential(mymap))
    end
    do
        local mymap = zmap:new()
        for i = 1, 20 do
            mymap:insert(i, math.random(1, 10))
        end
        mytest:assert_eq(mymap:size(), 20)
        mytest:assert_true(is_sequential(mymap))
    end
    do
        local mymap = zmap:new()
        for i = 0, 20 do
            mymap:insert(i, math.floor(i / 3))
        end
        mytest:assert_eq(mymap:size(), 21)
        mytest:assert_true(is_sequential(mymap))

        -- 排名检查
        local iter = mymap:at(1)
        mytest:assert_eq(iter:get()[1], 0)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(0), 1)
        local iter = mymap:at(2)
        mytest:assert_eq(iter:get()[1], 1)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(1), 2)
        local iter = mymap:at(3)
        mytest:assert_eq(iter:get()[1], 2)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(2), 3)
        local iter = mymap:at(4)
        mytest:assert_eq(iter:get()[1], 3)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(3), 4)
        local iter = mymap:at(5)
        mytest:assert_eq(iter:get()[1], 4)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(4), 5)
        local iter = mymap:at(6)
        mytest:assert_eq(iter:get()[1], 5)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(5), 6)
        local iter = mymap:at(7)
        mytest:assert_eq(iter:get()[1], 6)
        mytest:assert_eq(iter:get()[2], 2)
        mytest:assert_eq(mymap:rank(6), 7)

        local iter = mymap:xend()
        iter:advance(-1)
        mytest:assert_eq(iter:get()[1], 20)
        mytest:assert_eq(iter:get()[2], 6 )
        mytest:assert_eq(mymap:rank(iter:get()[1]), 21)

        local iter = mymap:xend()
        iter:advance(-2)
        mytest:assert_eq(iter:get()[1], 19)
        mytest:assert_eq(iter:get()[2], 6 )
        mytest:assert_eq(mymap:rank(iter:get()[1]), 20)

        local iter = mymap:xend()
        iter:advance(2)
        mytest:assert_eq(iter, mymap:xend())

        -- 移除操作
        mymap:erase(3)
        mytest:assert_eq(mymap:size(), 20)
        mytest:assert_true(is_sequential(mymap))
        local iter = mymap:at(1)
        mytest:assert_eq(iter:get()[1], 0)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(0), 1)
        local iter = mymap:at(2)
        mytest:assert_eq(iter:get()[1], 1)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(1), 2)
        local iter = mymap:at(3)
        mytest:assert_eq(iter:get()[1], 2)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(2), 3)
        local iter = mymap:at(4)
        mytest:assert_eq(iter:get()[1], 4)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(4), 4)
        local iter = mymap:at(5)
        mytest:assert_eq(iter:get()[1], 5)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(5), 5)
        local iter = mymap:at(6)
        mytest:assert_eq(iter:get()[1], 6)
        mytest:assert_eq(iter:get()[2], 2)
        mytest:assert_eq(mymap:rank(6), 6)

        -- 移除操作
        mymap:erase(mymap:xend())
        mytest:assert_eq(mymap:size(), 20)
        mytest:assert_true(is_sequential(mymap))

        -- 移除操作
        mymap:erase(mymap:xend():prev())
        mytest:assert_eq(mymap:size(), 19)
        mytest:assert_true(is_sequential(mymap))
        local iter = mymap:at(1)
        mytest:assert_eq(iter:get()[1], 0)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(0), 1)
        local iter = mymap:at(2)
        mytest:assert_eq(iter:get()[1], 1)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(1), 2)
        local iter = mymap:at(3)
        mytest:assert_eq(iter:get()[1], 2)
        mytest:assert_eq(iter:get()[2], 0)
        mytest:assert_eq(mymap:rank(2), 3)
        local iter = mymap:at(4)
        mytest:assert_eq(iter:get()[1], 4)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(4), 4)
        local iter = mymap:at(5)
        mytest:assert_eq(iter:get()[1], 5)
        mytest:assert_eq(iter:get()[2], 1)
        mytest:assert_eq(mymap:rank(5), 5)
        local iter = mymap:at(6)
        mytest:assert_eq(iter:get()[1], 6)
        mytest:assert_eq(iter:get()[2], 2)
        mytest:assert_eq(mymap:rank(6), 6)

        local iter = mymap:xend()
        iter:advance(-1)
        mytest:assert_eq(iter:get()[1], 19)
        mytest:assert_eq(iter:get()[2], 6 )
        mytest:assert_eq(mymap:rank(iter:get()[1]), 19)

        local iter = mymap:xend()
        iter:advance(-2)
        mytest:assert_eq(iter:get()[1], 18)
        mytest:assert_eq(iter:get()[2], 6 )
        mytest:assert_eq(mymap:rank(iter:get()[1]), 18)

        local iter = mymap:at(20)
        mytest:assert_eq(iter, mymap:xend())

        mymap:clear()
        mytest:assert_eq(mymap:size(), 0)
        mytest:assert_true(is_sequential(mymap))
    end
end

function mytest.testB()
    do
        local mymap = zmap:new()
        for i = 1, 5 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 5)
        mytest:assert_true(is_sequential(mymap))
        mytest:assert_eq(1  , mymap:get(1))
        mytest:assert_eq(2  , mymap:get(2))
        mytest:assert_eq(3  , mymap:get(3))
        mytest:assert_eq(4  , mymap:get(4))
        mytest:assert_eq(5  , mymap:get(5))
        mytest:assert_eq(nil, mymap:get(6))

        mymap:set(6, 6)
        mytest:assert_eq(mymap:size(), 6)
        mytest:assert_true(is_sequential(mymap))
        mytest:assert_eq(1  , mymap:get(1))
        mytest:assert_eq(2  , mymap:get(2))
        mytest:assert_eq(3  , mymap:get(3))
        mytest:assert_eq(4  , mymap:get(4))
        mytest:assert_eq(5  , mymap:get(5))
        mytest:assert_eq(6  , mymap:get(6))

        mymap:set(3, 6)
        mytest:assert_eq(mymap:size(), 6)
        mytest:assert_true(is_sequential(mymap))
        mytest:assert_eq(1, mymap:get(1))
        mytest:assert_eq(2, mymap:get(2))
        mytest:assert_eq(6, mymap:get(3))
        mytest:assert_eq(4, mymap:get(4))
        mytest:assert_eq(5, mymap:get(5))
        mytest:assert_eq(6, mymap:get(6))
        mytest:assert_eq(1, mymap:rank(1))
        mytest:assert_eq(2, mymap:rank(2))
        mytest:assert_eq(6, mymap:rank(3))
        mytest:assert_eq(3, mymap:rank(4))
        mytest:assert_eq(4, mymap:rank(5))
        mytest:assert_eq(5, mymap:rank(6))

        local iter = mymap:find(4)
        mytest:assert_eq(4, iter:get()[1])
        mytest:assert_eq(4, iter:get()[2])

        local iter = mymap:find(3)
        mytest:assert_eq(3, iter:get()[1])
        mytest:assert_eq(6, iter:get()[2])

        for i = 1, 7 do
            mymap:erase(i)
        end
        mytest:assert_eq(mymap:size(), 0)
        mytest:assert_true(is_sequential(mymap))
    end
end

function mytest.testC()
    do
        local mymap = zmap:new()
        for i = 1, 5 do
            mymap:insert(i + 0, i)
            mymap:insert(i + 5, i)
        end
        mytest:assert_eq(mymap:size(), 10)
        mytest:assert_true(is_sequential(mymap))

        local iter1 = mymap:lower_bound(2)
        local iter2 = mymap:lower_bound(4)
        local iter3 = mymap:upper_bound(4)
        local iter4 = mymap:upper_bound(7)
        mytest:assert_eq(4, iter1:distance(iter2))
        mytest:assert_eq(6, iter1:distance(iter3))
        mytest:assert_eq(2, iter2:distance(iter3))
        mytest:assert_eq(8, iter1:distance(iter4))
    end
end

function mytest.testD()
    do
        local mymap = zmap:new()
        for i = 1, 5 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 5)
        mytest:assert_true(is_sequential(mymap))

        local iter = mymap:xbegin()
        iter:advance(-1)
        mytest:assert_eq(iter, mymap:xend())

        local iter = mymap:xbegin()
        iter:advance(-2)
        mytest:assert_eq(iter, mymap:xend())

        local iter = mymap:xbegin()
        iter:advance(5)
        mytest:assert_eq(iter, mymap:xend())

        local iter = mymap:xbegin()
        iter:advance(6)
        mytest:assert_eq(iter, mymap:xend())

        local iter = mymap:xbegin()
        iter:advance(4)
        mytest:assert_eq(5, iter:get()[1])

        local iter1 = mymap:xbegin()
        local iter2 = mymap:xend()
        iter1:advance( 4)
        iter2:advance(-1)
        mytest:assert_eq(iter1, iter2)

    end
end

function mytest.testE()
    do
        local mymap = zmap:new()
        for i = 1, 1000000 do
            mymap:insert(i, i)
        end
        mytest:assert_eq(mymap:size(), 1000000)
        mytest:assert_true(is_sequential(mymap))
    end
end

mytest:run()
