-------------------------------------------------------------------------------
--- 容器适配器，优先级队列的第一个元素总是'最大'/'最小'元素。
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"

-------------------------------------------------------------------------------
--- 队列定义
local queue = newclass("priority-queue")

function queue:init(obj, compare)
    -- 调整比较逻辑
    if (type(compare) ~= "function") then
        compare = function(a, b)
            return a > b
        end
    end
    self.__compare = compare
    self.__deque   = require("luamon.container.deque"):new(obj)
    algorithm.make_heap(self.__deque:xbegin(), self.__deque:xend(), self.__compare)
end

function queue:size()
    return self.__deque:size()
end

function queue:empty()
    return self.__deque:empty()
end

function queue:top()
    return self.__deque:front()
end

function queue:push(v)
    self.__deque:push_back(v)
    algorithm.push_heap(self.__deque:xbegin(), self.__deque:xend(), self.__compare)
end

function queue:pop(v)
    algorithm.pop_heap(self.__deque:xbegin(), self.__deque:xend(), self.__compare)
    self.__deque:pop_back(v)
end

return queue
