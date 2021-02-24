-------------------------------------------------------------------------------
--- Arrays are fixed-size sequence containers: they hold a specific 
--- number of elements ordered in a strict linear sequence.
-------------------------------------------------------------------------------
require "luamon.class"

---------------------------------------------------------------------
--- 'Array'实例与其私有数据的映射关系
local mtable = {}
setmetatable(mtable, {__mode = "k"})

---------------------------------------------------------------------
--- 'Array'定义
local Array = newclass("Array")

-- 构造函数
function Array.init(inst, size)
    assert(math.floor(size) == size)
    assert(mtable[inst] == nil)
    local data = 
    {
    }
end
