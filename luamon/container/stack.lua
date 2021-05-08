-------------------------------------------------------------------------------
--- 容器适配器，专门设计用于实现'FILO'操作。
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 栈定义
local stack = newclass("luamon.container.stack")

function stack:init(obj)
    self.__deque = require("luamon.container.deque"):new(obj)
end

function stack:size()
    return self.__deque:size()
end

function stack:empty()
    return self.__deque:empty()
end

function stack:top()
    return self.__deque:back()
end

function stack:push(v)
    self.__deque:push_back(v)
end

function stack:pop()
    self.__deque:pop_back()
end

function stack:__len()
    return self:size()
end

function stack:__pairs()
    error("this function not implemented.")
end

return stack
