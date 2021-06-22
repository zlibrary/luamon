-------------------------------------------------------------------------------
--- 行为树框架，参考'https://github.com/BehaviorTree/BehaviorTree.cpp'实现
-------------------------------------------------------------------------------
require "luamon"
local blackboard = require "luamon.ai.behavior-tree.blackboard"

-- 生成行为树节点
-- 1. 节点配置
-- 2. 黑板对象
-- 3. 子树集合
local function make_behavior_node(nc, bb, subtrees)
    local node = require(nc.modname):new(bb, nc.imports, nc.exports)
    -- 注册监控器
    if nc.observers then
        for _, method in ipairs(nc.observers) do
            node:subscribe(method)
        end
    end
    -- 条件节点
    if (node:type() == node.class.category.condition) then
        return node
    end
    -- 行为节点
    if (node:type() == node.clazz.category.action) then
        return node
    end
    -- 控制节点
    if (node:type() == node.class.category.control) then
        for _, cc in ipairs(nc.children) do
            node:add_child(make_behavior_node(cc, bb, subtrees))
        end
        return node
    end
    -- 修饰节点
    if (node:type() == node.class.category.decorator) then
        for _, cc in ipairs(nc.children) do
            node:set_child(make_behavior_node(cc, bb, subtrees))
        end
        return node
    end
    -- 行为子树
    if (node:type() == node.class.category.subtree) then
        -- 构建子树黑板
        local sb = blackboard:new(bb)
        for k, v in pairs(nc.mapping or {}) do
            sb:redirect(k, v)
        end
        -- 查找子树配置
        local sc = subtrees[nc.subtree]
        if (sc == nil) then
            error(string.format("subtree[%s] undefined.", nc.subtree))
        else
            node:set_child(make_behavior_node(sc, sb, subtrees))
        end
        return node
    end
    -- 节点类型异常
    error(string.format("module[%s] : unknown category.", nc.modname))
end

-------------------------------------------------------------------------------
-- 行为树生成模块
return
{
    create = function(config)
        local mtree = config.maintree
        if (mtree == nil) then
            error("maintree is undefined.")
        end
        local maintree = assert(config.maintree, "maintree undefined.")
        local sub


        local trees = {}

        
    end
}
