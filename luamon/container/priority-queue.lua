-------------------------------------------------------------------------------
--- 容器适配器，优先级队列的第一个元素总是'最大'/'最小'元素。
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 队列定义
local queue = newclass("priority-queue")

function queue:init(obj, compare)
    assert(type(compare) == "function")
    self.__compare = compare
    self.__deque   = require("luamon.container.deque"):new(obj)
    

end
