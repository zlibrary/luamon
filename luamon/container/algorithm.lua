-------------------------------------------------------------------------------
--- 容器相关方法集
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local algorithm = {}

function algorithm.distance(first, last)
    return first:distance(last)
end

function algorithm.copy(first, last, result)
    while(first ~= last) do
        result:set(first:get())
        first:advance(1)
        result:advance(1)
    end
end

function algorithm.fill(first, last, v)
    while(first ~= last) do
        first:set(v)
        first:advance(1)
    end
end


-------------------------------------------------------------------------------
--- 堆排序相关逻辑

-- 堆重整逻辑（用于数组新增元素后堆结构重整 - 元素向上调整过程）
-- 1. 数组起点
-- 2. 元素索引
-- 3. 索引上限
-- 4. 元素内容
-- 5. 比较逻辑
local function __push_heap(first, hole, top, value, compare)
    local parent = math.floor((hole - 1) / 2)
    while ((hole > top) and compare(value, (first + parent):get())) do
        (first + hole):set((first + parent):get())
        hole = parent
        parent = math.floor((hole - 1) / 2)
    end
    (first + hole):set(value)
end

-- 堆重整逻辑（用于数组新增元素后堆结构重整 - 元素向上调整过程）
-- 1. 数组起点
-- 2. 数组终点
-- 3. 比较逻辑
function algorithm.push_heap(first, last, compare)
    assert(first:isa("random-access"))
    assert(last :isa("random-access"))
    local value = (last - 1):get()
    local hole  = first:distance(last) - 1
    __push_heap(first, hole, 0, value, compare)
end

-- 堆重整逻辑（默认左右子树是有效堆结构）
-- 1. 数组起点
-- 2. 元素索引
-- 3. 数组长度
-- 4. 元素内容
-- 5. 比较逻辑
local function __adjust_heap(first, hole, length, value, compare)
    local rchild = hole
    local top    = hole
    while(rchild < math.floor((length - 1) / 2)) do
        -- 存在右子树
        rchild = (rchild + 1) * 2
        if compare((first + rchild - 1):get(), (first + rchild):get()) then
            rchild = rchild - 1
        end
        (first + hole):set((first + rchild):get())
        hole = rchild
    end
    if (hole == math.floor((length - 2) / 2)) then
        -- 存在左子树
        (first + hole):set((first + (hole * 2 + 1)):get())
        hole = hole * 2 + 1
    end
    __push_heap(first, hole, top, value, compare)
end

-- 堆重整逻辑（用于取出堆顶元素后的堆结构重整 - 元素向下调整过程）
-- 1. 数组起点
-- 2. 数组终点
-- 3. ？？
-- 4. 比较逻辑
local function __pop_heap(first, last, result, compare)
    local value = result:get()
    result:set(first:get())
    __adjust_heap(first, 0, first:distance(last), value, compare)
end

-- 堆重整逻辑（用于取出堆顶元素后的堆结构重整 - 元素向下调整过程）
-- 1. 数组起点
-- 2. 数组终点
-- 3. 比较逻辑
function algorithm.pop_heap(first, last, compare)
    assert(first:isa("random-access"))
    assert(last :isa("random-access"))
    local length = first:distance(last)
    if (length > 1) then
        last = last - 1
        __pop_heap(first, last, last, compare)
    end
end

-- 构造堆结构（指定数组构造成有效堆结构）
-- 1. 数组起点
-- 2. 数组终点
-- 3. 比较逻辑
function algorithm.make_heap(first, last, compare)
    assert(first:isa("random-access"))
    assert(last :isa("random-access"))
    local length = first:distance(last)
    if (length < 2) then
        return
    end
    local parent = math.floor((length - 2) / 2)
    while(true) do
        local value = (first + parent):get()
        __adjust_heap(first, parent, length, value, compare)
        if (parent == 0) then
            return
        else
            parent = parent - 1
        end
    end
end

-- 堆排序逻辑（将有效堆结构原地排序）
-- 1. 数组起点
-- 2. 数组终点
-- 3. 比较逻辑
function algorithm.sort_heap(first, last, compare)
    assert(first:isa("random-access"))
    assert(last :isa("random-access"))
    while(first:distance(last) > 1) do
        last = last - 1
        __pop_heap(first, last, last, compare)
    end
end

return algorithm
