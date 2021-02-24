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

function Array:init(size)
    -- 修正数组

    local data = 
    {
    }
end
