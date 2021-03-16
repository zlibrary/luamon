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


function algorithm.make_heap(first, last)
    assert(first:isa("random-access"))
    assert(last :isa("random-access"))
    local length = first:distance(last)
    if (length < 2) then
        return
    end
    

    local parent = length


    if (first:distance(last) < 2) then
        return
    end
end



return algorithm
