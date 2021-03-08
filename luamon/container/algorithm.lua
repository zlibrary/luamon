-------------------------------------------------------------------------------
--- 容器相关方法集
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local algorithm = {}

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
