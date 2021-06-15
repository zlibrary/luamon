-------------------------------------------------------------------------------
--- 行为树修饰节点(在树中不能作为叶子存在)
-------------------------------------------------------------------------------
require "luamon"
local treenode = require "luamon.ai.behavior-tree.treenode"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.bt-decorator", treenode)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
end

function clazz:set_child(child)
    if (self.child ~= nil) then
        error("child has already exists.")
    end
    if (true == treenode:made(child)) then
        self.child = child
    else
        error("child must be a treenode.")
    end
end

function clazz:type()
    return treenode.category.decorator
end

function clazz:halt()
    local child = self.child
    if (not child) then
        return
    end
    if (child:is_running() == true) then
        child:halt()
    end
    child:set_status(treenode.status.idle)
end

function clazz:exec()
    local status = self.super:exec()
    if (self.child:is_success() or self.child:is_failure()) then
        self.child:set_status(treenode.status.idle)
    end
    return status
end

return clazz
