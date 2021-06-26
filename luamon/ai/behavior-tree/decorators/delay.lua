-------------------------------------------------------------------------------
--- 行为树修饰节点
-------------------------------------------------------------------------------
require "luamon"
local decorator = require "luamon.ai.behavior-tree.bt-decorator"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.decorators.delay", decorator)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
    self.times = 0
end

function clazz:halt()
    self.times = 0
    self.super:halt()
end

function clazz:tick()
    local times = assert(self:get("decorator_delay_times"), "Missing parameter[decorator_delay_times].")
    self:set_status(clazz.status.running)
    if (self.times >= times) then
        return self.object:exec()
    else
        self.times = self.times + 1
        return clazz.status.running
    end
end

return clazz