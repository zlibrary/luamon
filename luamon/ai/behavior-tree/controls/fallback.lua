-------------------------------------------------------------------------------
--- 行为树控制节点
-------------------------------------------------------------------------------
require "luamon"
local control = require "luamon.ai.behavior-tree.bt-control"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.controls.fallback", control)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
    self.index = 0
end

function clazz:halt()
    self.index = 0
    self.super:halt()
end

function clazz:tick()
    local children_count = self:get_children_count()
    self:set_status(clazz.status.running)
    while(self.index < children_count) do
        local mchild = self.children[self.index + 1]
        local status = mchild:exec()
        if (status == clazz.status.running) then
            return clazz.status.running
        end
        if (status == clazz.status.idle) then
            error("control.child never return idle.")
        end
        if (status == clazz.status.success) then
            self.super:halt()
            self.index = 0
            return clazz.status.success
        else
            self.index = self.index + 1
        end
    end
    if (self.index == children_count) then
        self.index = 0
        self.super:halt()
    end
    return clazz.status.failure
end

return clazz
