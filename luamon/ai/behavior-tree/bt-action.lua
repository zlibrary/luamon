-------------------------------------------------------------------------------
--- 行为树动作节点(在树中只能作为叶子存在)
-------------------------------------------------------------------------------
require "luamon"
local treenode = require "luamon.ai.behavior-tree.treenode"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.bt-action", treenode)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
end

function clazz:type()
    return treenode.category.action
end

function clazz:halt()
    self:set_status(treenode.status.idle)
end

return clazz
