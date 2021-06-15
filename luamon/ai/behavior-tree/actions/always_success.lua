-------------------------------------------------------------------------------
--- 行为树动作节点
-------------------------------------------------------------------------------
require "luamon"
local action = require "luamon.ai.behavior-tree.bt-action"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.actions.always_success", action)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
end

function clazz:tick()
    return clazz.status.success
end

return clazz

