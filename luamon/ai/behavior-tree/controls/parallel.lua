-------------------------------------------------------------------------------
--- 行为树控制节点
-------------------------------------------------------------------------------
require "luamon"
local control = require "luamon.ai.behavior-tree.bt-control"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.controls.parallel", control)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
    self.finished = {}
end

function clazz:halt()
    self.finished={}
    self.super:halt()
end

function clazz:tick()
    local success_threshold = assert(self:get("parallel_success_threshold"), "Missing parameter[parallel_success_threshold].")
    local failure_threshold = assert(self:get("parallel_failure_threshold"), "Missing parameter[parallel_failure_threshold].")
    local children_count = self:get_children_count()
    if (children_count < success_threshold) then
        error("number of children is less then parallel_success_threshold.")
    end
    if (children_count < failure_threshold) then
        error("number of children is less then parallel_failure_threshold.")
    end
    local success_threshold_num = 0
    local failure_threshold_num = 0
    for i = 1, children_count do
        local mchild = self.children[i]
        local status = self.finished[i]
        if (status == nil) then
            status = mchild:exec()
        end
        if (status == clazz.status.success) then
            success_threshold_num = success_threshold_num + 1
            if (success_threshold_num == success_threshold) then
                self.finished={}
                self.super:halt()
                return clazz.status.success
            else
                self.finished[i] = clazz.status.success
            end
        end
        if (status == clazz.status.failure) then
            failure_threshold_num = failure_threshold_num + 1
            if (failure_threshold_num == failure_threshold) then
                self.finished={}
                self.super:halt()
                return clazz.status.failure
            else
                self.finished[i] = clazz.status.failure
            end
        end
        if (status == clazz.status.running) then
            break
        end
        if (status == clazz.status.idle) then
            error("control.child never return idle.")
        end
    end
    return clazz.status.running
end

return clazz
