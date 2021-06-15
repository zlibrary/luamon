-------------------------------------------------------------------------------
--- 行为树修饰节点
-------------------------------------------------------------------------------
require "luamon"
local decorator = require "luamon.ai.behavior-tree.bt-decorator"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.decorators.simple", decorator)

function clazz:init(method, blackboard, imports, exports)
    assert(type(method) == "function")
    self.super:init(blackboard, imports, exports)
    self.method = method
end

function clazz:tick()
    return self:method(self.child:exec())
end

return clazz
