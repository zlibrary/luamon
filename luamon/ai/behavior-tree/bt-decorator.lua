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

function clazz:set_object(obj)
    if (self.object ~= nil) then
        error("object has already exists.")
    end
    if (true == treenode:made(obj)) then
        self.object = obj
    else
        error("object must be a treenode.")
    end
end

function clazz:type()
    return treenode.category.decorator
end

function clazz:halt()
    local object = self.object
    if (not object) then
        return
    end
    if (object:is_running() == true) then
        object:halt()
    end
    self:set_status(treenode.status.idle)
end

return clazz
