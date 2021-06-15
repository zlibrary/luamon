-------------------------------------------------------------------------------
--- 行为树控制节点(在树中不能作为叶子存在)
-------------------------------------------------------------------------------
require "luamon"
local treenode = require "luamon.ai.behavior-tree.treenode"

-------------------------------------------------------------------------------
local clazz = newclass("luamon.ai.behavior-tree.bt-control", treenode)

function clazz:init(blackboard, imports, exports)
    self.super:init(blackboard, imports, exports)
    self.count    = 0
    self.children = {}
end

function clazz:add_child(child)
    if (true == treenode:made(child)) then
        self.count = self.count + 1
        table.insert(self.children, child)
    else
        error("child must be a treenode.")
    end
end

function clazz:get_child_count()
    return self.count
end

function clazz:type()
    return treenode.category.control
end

function clazz:halt()
    for _, child in ipairs(self.children) do
        if child:is_running() then
            child:halt()
        end
        child:set_status(treenode.status.idle)
    end
end

return clazz
