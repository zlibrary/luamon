-------------------------------------------------------------------------------
--- 行为树动作节点
-------------------------------------------------------------------------------
require "luamon"
local action = require "luamon.ai.behavior-tree.bt-action"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.actions.simple", action)

function clazz:init(method, blackboard, imports, exports)
    assert(type(method) == "function")
    self.super:init(blackboard, imports, exports)
    self.method = method
end

function clazz:tick()
    if self:is_halt() then
        self:set_status(clazz.status.running)
    end
    return self:method()
end

return clazz
