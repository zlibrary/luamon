-------------------------------------------------------------------------------
--- 'luamon.container.zmap'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local zmap      = require 'luamon.container.zmap'

-- 秩序检查
local function is_sequential(mymap)
    local iter1 = mymap:xbegin()
    local iter2 = iter1 + 1
    while(iter2 ~= mymap:xend()) do
        local v1 = iter1:get()
        local v2 = iter2:get()
        if not mymap.__linked.kcompare(v1[2], v2[2]) then
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

    print("\n---------------------")

    do
        local mymap = zmap:new()
        for i = 1, 3 do
            mymap:insert(i, i)
        end

        local iter = mymap:xbegin()
        iter:advance(1)
        -- -- while(true) do

        -- --     if iter == mymap:xend() then
        -- --         break
        -- --     end

        -- --     print("----- : ", iter:get()[1], iter:get()[2])
        -- --     iter:advance(1)
        -- -- end
        -- mytest:assert_eq(mymap:size(), 20)
        -- mytest:assert_true(is_sequential(mymap))
    end

end

mytest:run()
