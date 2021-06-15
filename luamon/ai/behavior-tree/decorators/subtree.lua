-------------------------------------------------------------------------------
--- 行为树修饰节点
-------------------------------------------------------------------------------
require "luamon"
local decorator = require "luamon.ai.behavior-tree.bt-decorator"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.decorators.subtree", decorator)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
end

function clazz:type()
    return clazz.category.subtree
end

function clazz:tick()
    if self:is_halt() then
        self.set_status(clazz.status.running)
    end
    return self.child:exec()
end

return clazz
