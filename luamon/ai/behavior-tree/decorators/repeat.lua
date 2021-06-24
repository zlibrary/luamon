-------------------------------------------------------------------------------
--- 行为树修饰节点
-------------------------------------------------------------------------------
require "luamon"
local decorator = require "luamon.ai.behavior-tree.bt-decorator"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.decorators.repeat", decorator)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
    self.index = 0
end

function clazz:tick()
    local times = assert(self:get("decorator_repeat_times"), "Missing parameter[decorator_repeat_times].")
    self:set_status(clazz.status.running)
    while((times == -1) or (times > self.index)) do
        local status = self.heirs:exec()
        if (status == clazz.status.running) then
            return clazz.status.running
        end
        if (status == clazz.status.idle) then
            error("decorator.child never return idle.")
        end
        if (status == clazz.status.success) then
            self.index = self.index + 1
            self.heirs:halt()
        else
            self.heris:halt()
            self.index = 0
            return clazz.status.failure
        end
    end
    self.index = 0
    return clazz.status.success
end

return clazz
