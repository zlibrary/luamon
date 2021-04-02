-------------------------------------------------------------------------------
--- 容器适配器，专门设计用于实现'FIFO'操作。
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 队列定义
local queue = newclass("queue")

function queue:init(obj)
    self.__deque = require("luamon.container.deque"):new(obj)
end

function queue:size()
    return self.__deque:size()
end

function queue:empty()
    return self.__deque:empty()
end

function queue:front()
    return self.__deque:front()
end

function queue:back()
    return self.__deque:back()
end

function queue:push(v)
    self.__deque:push_back(v)
end

function queue:pop()
    self.__deque:pop_front()
end

return queue
