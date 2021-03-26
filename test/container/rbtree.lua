-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local RBTree    = require 'luamon.container.rbtree'

-- 构建测试实例
local mytest = TestSuite.new()

-- 秩序检查
local function is_sequential(mytree, unique)
    local iter1 = mytree:xbegin()
    local iter2 = iter1 + 1
    while(iter2 ~= mytree:xend()) do
        local v1 = iter1:get()
        local v2 = iter2:get()
        if not mytree.kcompare(mytree.kextract(v1), mytree.kextract(v2)) then
            if unique then
                return false
            end
            if mytree.kcompare(mytree.kextract(v2), mytree.kextract(v1)) then
                return false
            end
        end
        iter1 = iter2
        iter2 = iter1 + 1
    end
    return true
end

-- 高度检查
local function is_rbtree(mytree)

    -- 获取节点高度
    local function height(node)
        local lheight = (node.lchild == nil) and 0 or height(node.lchild)
        local rheight = (node.rchild == nil) and 0 or height(node.rchild)
        return math.max(lheight, rheight) + ((node.color == 2) and 1 or 0)
    end

    -- 均衡检查
    local function is_balance(node)
        local cheight = height(node)
        if (cheight <= 1) then
            return true
        else
            local lheight = height(node.lchild)
            local rheight = height(node.rchild)
            if (lheight ~= rheight) then
                return false
            else
                return is_balance(node.lchild) and is_balance(node.rchild) 
            end
        end
    end

    local root = mytree.header.parent
    if (root == nil) then
        return true
    else
        return is_balance(root)
    end
end

-- 打印一颗树
local function ptree(mytree)
    -- 打印一行
    local function pline(vtbl)
        local ntbl = {}
        local str  = ""
        for _, v in ipairs(vtbl) do
            if type(v) == "table" then
                str = str .. string.format("{value = %s, color = %s}, ", v.value, v.color)
                table.insert(ntbl, v.lchild or "nil")
                table.insert(ntbl, v.rchild or "nil")
            else
                str = str .. v .. ", "
            end
        end
        print(str)
        if #ntbl > 0 then
            pline(ntbl)
        end
    end
    print("")
    pline({ mytree.header.parent })
end

-- 插入测试
function mytest.testA()

    do
        local mytree = RBTree:new()
        mytest:assert_eq(mytree:size(), 0)
        mytest:assert_true(is_sequential(mytree, "unique"))
        mytest:assert_true(is_sequential(mytree))
        mytest:assert_true(is_rbtree(mytree))
    end

    do
        local mytree = RBTree:new()
        for i = 1, 20 do
            mytree:insert_unique(i)
        end
        mytest:assert_eq(mytree:size(), 20)
        mytest:assert_true(is_sequential(mytree, "unique"))
        mytest:assert_true(is_rbtree(mytree))
    end

    do
        local mytree = RBTree:new()
        for _, v in ipairs({45, 67, 12, 34, 56, 41, 75, 89, 13, 26, 62, 14, 15, 61, 64, 42, 47, 49, 50, 70}) do
            mytree:insert_unique(v)
        end
        mytest:assert_eq(mytree:size(), 20)
        mytest:assert_true(is_sequential(mytree, "unique"))
        mytest:assert_true(is_rbtree(mytree))

        local iter = mytree:xbegin()
        mytest:assert_eq(iter:get(), 12)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 13)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 14)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 15)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 26)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 34)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 41)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 42)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 45)
    end

    do
        local mytree = RBTree:new()
        for _, v in ipairs({45, 67, 12, 34, 56, 47, 75, 89, 13, 26, 62, 14, 15, 61, 64, 42, 47, 49, 50, 12}) do
            mytree:insert_equal(v)
        end
        mytest:assert_eq(mytree:size(), 20)
        mytest:assert_false(is_sequential(mytree, "unique"))
        mytest:assert_true (is_sequential(mytree          ))
        mytest:assert_true (is_rbtree(mytree))

        local iter = mytree:xbegin()
        mytest:assert_eq(iter:get(), 12)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 12)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 13)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 14)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 15)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 26)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 34)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 42)
        iter:advance(1)
        mytest:assert_eq(iter:get(), 45)
    end

    do
        local mytree = RBTree:new()
        for _, v in ipairs({7121,3053,6114,2044,6126,5107,2047,6142,3075,7173,4108,9239,516,1032,7209,520,9319,1042,6218,6222,8368,526,6246,5235,1056,5243,7293,2116,5267,5271,7321,6302,3157,535,5299,7353,3169,9615,1079,7385,4320,6378,6386,1088,6394,9727,7437,4376,2192,1098,8776,4396,8800,2210,7497,2218,2220,8872,1113,2226,6498,7525,3257,9951,561,4480,2244,9999,5523,7573,6554,1130,1133,7597,3297,2276,9096,7637,6618,2290,1147,3319,3329,2310,4620,581,7713,146,8289,7733,6718,7757,588,8361,6746,295,3383,9432,6008,6778}) do
            mytree:insert_unique(v)
        end
        mytest:assert_eq(mytree:size(), 100)
        mytest:assert_true(is_sequential(mytree, "unique"))
        mytest:assert_true(is_rbtree(mytree))
    end

    do
        local mytree = RBTree:new()
        for _, v in ipairs({137,192,215,138,162,2,81,58,208,133,71,196,66,105,154,128,103,16,29,242,263,296,156,85,54,108,132,256,205,236,116,42,128,31,180,290,33,260,48,240,94,119,137,160,223,291,287,27,7,16,269,269,12,126,55,66,233,187,23,138,123,138,180,250,169,61,241,202,22,288,143,115,108,279,275,31,270,262,58,276,278,27,246,290,153,2,57,86,188,79,224,11,216,105,261,86,166,202,287,187}) do
            mytree:insert_equal(v)
        end
        mytest:assert_eq(mytree:size(), 100)
        mytest:assert_false(is_sequential(mytree, "unique"))
        mytest:assert_true (is_sequential(mytree))
        mytest:assert_true(is_rbtree(mytree))
    end
end

-- 边界测试
function mytest.testB()
    do
        local mytree = RBTree:new()
        mytest:assert_eq(mytree:lower_bound(3), mytree:xend())
        mytest:assert_eq(mytree:upper_bound(3), mytree:xend())
        mytest:assert_eq(mytree:equal_count(3), 0)

        mytree:insert_equal(3)
        for i = 1, 20 do
            mytree:insert_equal(i)
        end
        mytree:insert_equal(3)
        mytree:insert_equal(3)
        local lv = mytree:lower_bound(3)
        local uv = mytree:upper_bound(3)
        mytest:assert_ne((uv + 0):get(), 3)
        mytest:assert_eq((uv - 1):get(), 3)
        mytest:assert_ne((lv - 1):get(), 3)
        mytest:assert_eq((lv + 0):get(), 3)
        mytest:assert_eq((lv + 1):get(), 3)
        mytest:assert_eq((lv + 2):get(), 3)
        mytest:assert_eq(mytree:equal_count(3), 4)
        mytest:assert_eq(mytree:find(99), mytree:xend())
        mytest:assert_ne(mytree:find(20), mytree:xend())

        mytest:assert_error(function()
            mytest:xend():distance(mytest:xbegin())
        end)

        mytest:assert_error(function()
            mytest:xend():distance(mytest:xbegin())
        end)

        mytest:assert_eq(mytree:xbegin():distance(mytree:xend()), 23)

    end
end

mytest:run()