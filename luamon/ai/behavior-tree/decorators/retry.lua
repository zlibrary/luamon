-------------------------------------------------------------------------------
--- 行为树修饰节点
-------------------------------------------------------------------------------
require "luamon"
local decorator = require "luamon.ai.behavior-tree.bt-decorator"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.decorators.retry", decorator)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
    self.index = 0
end

function clazz:halt()
    self.index = 0
    self.super:halt()
end

function clazz:tick()
    local times = assert(self:get("decorator_retry_times"), "Missing parameter[decorator_retry_times].")
    self:set_status(clazz.status.running)
    while((times == -1) or (times > self.index)) do
        local status = self.object:exec()
        if (status == clazz.status.running) then
            return clazz.status.running
        end
        if (status == clazz.status.idle) then
            error("decorator.object never return idle.")
        end
        if (status == clazz.status.success) then
            self.object:halt()
            self.index = 0
            return clazz.status.success
        else
            self.object:halt()
            self.index = self.index + 1
        end
    end
    self.index = 0
    return clazz.status.failure
end

return clazz
