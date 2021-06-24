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
    if (type(nc.modname) == 'string') and (string.lower(nc.modname) == 'subtree') then
        -- 构建子树黑板
        local sb = blackboard:new(bb)
        for k, v in pairs(nc.mapping or {}) do
            sb:redirect(k, v)
        end
        -- 查找子树配置
        local sc = subtrees[nc.subtree]
        if (sc == nil) then
            error(string.format("subtree[%s] is undefined.", nc.subtree))
        else
            return make_behavior_node(sc, sb, subtrees)
        end
    else
        local node = nil
        if (type(nc.modname) == 'function') then
            node = nc.modname(bb, nc.imports, nc.exports)
        else
            node = require(nc.modname):new(bb, nc.imports, nc.exports)
        end
        if (node == nil) then
            error(string.format("node[%s] : create failed.", nc.modname))
        end
        -- 注册监控器
        if nc.monitors then
            for _, monitor in ipairs(nc.monitors) do
                node:subscribe(monitor)
            end
        end
        -- 条件节点
        if (node:type() == node.class.category.condition) then
            return node
        end
        -- 行为节点
        if (node:type() == node.class.category.action) then
            return node
        end
        -- 修饰节点
        if (node:type() == node.class.category.decorator) then
            node:set_child(make_behavior_node(nc.child, bb, subtrees))
            return node
        end
        -- 控制节点
        if (node:type() == node.class.category.control) then
            for _, cc in ipairs(nc.children) do
                node:add_child(make_behavior_node(cc, bb, subtrees))
            end
            return node
        end
        -- 节点类型异常
        error(string.format("node[%s] : unknown category.", nc.modname))
    end
end

-------------------------------------------------------------------------------
-- 行为树生成模块
return
{
    create = function(config)
        local mbb = blackboard:new()
        local mbt = make_behavior_node(config.maintree, mbb, config.subtrees)
        local obj = 
        {
            -- 判断是否运行状态
            is_running = function()
                return mbt:is_running()
            end,

            -- 判断是否空闲状态
            is_halt = function()
                return mbt:is_halt()
            end,

            -- 判断是否操作成功
            is_success = function()
                return mbt:is_success()
            end,

            -- 判断操作是否失败
            is_failure = function()
                return mbt:is_failure()
            end,

            -- 停止行为树
            halt = function()
                return mbt:halt()
            end,

            -- 执行行为树
            exec = function()
                return mbt:exec()
            end,
        }
        return obj
    end
}
