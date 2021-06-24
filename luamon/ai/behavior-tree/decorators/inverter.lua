-------------------------------------------------------------------------------
--- 行为树修饰节点
-------------------------------------------------------------------------------
require "luamon"
local decorator = require "luamon.ai.behavior-tree.bt-decorator"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.decorators.inverter", decorator)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
end

function clazz:tick()
    self:set_status(clazz.status.running)
    local status = self.heirs:exec()
    if (status == clazz.status.success) then
        return clazz.status.failure
    end
    if (status == clazz.status.failure) then
        return clazz.status.success
    end
    if (status == clazz.status.running) then
        return clazz.status.running
    else
        error("decorator.child never return idle.")
    end
end

return clazz
