-------------------------------------------------------------------------------
--- 容器相关方法集
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local algorithm = {}

function algorithm.foreach(first, last, pred)
    while(first ~= last) do
        local next = (first + 1)
        pred(first)
        first = next
    end
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

return algorithm
