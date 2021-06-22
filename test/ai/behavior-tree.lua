-------------------------------------------------------------------------------
--- 行为树测试
-------------------------------------------------------------------------------
local TestSuite  = require 'luamon.ltest'
local blackboard = require 'luamon.ai.behavior-tree.blackboard'
local action     = require 'luamon.ai.behavior-tree.actions.simple'
local fallback   = require 'luamon.ai.behavior-tree.controls.fallback'
local sequence   = require 'luamon.ai.behavior-tree.controls.sequence'


-- 构建测试实例
local mytest = TestSuite.new()


-- 巡逻模拟
function mytest.testA()

    -- local bb = blackboard:new()
    -- local bt = fallback:new(bb)

    -- -- 查找敌人
    -- local lookup = action:new(function(this)
    --     if (math.random(1, 99) <= 55) then
    --         print("lookup failure")
    --         return action.status.failure
    --     else
    --         print("lookup success")
    --         this:set("coordinate", {1, 5})
    --         return action.status.success
    --     end
    -- end, bb, {}, { coordinate = '{coordinate}' })

    -- -- 攻击敌人
    -- local attack = action:new(function(this)
    --     local coordinate = this:get("coordinate")
    --     if (coordinate == nil) then
    --         print("attack error.")
    --     else
    --         print("attack ok", coordinate[1], coordinate[2])
    --     end
    --     return action.status.success
    -- end, bb, { coordinate = '{coordinate}' }, {})

    -- -- 顺序节点
    -- local se = sequence:new(bb, {}, {})
    -- se:add_child(lookup)
    -- se:add_child(attack)

    -- -- 自动巡逻
    -- local patrol = action:new(function()
    --     print("patrol")
    --     if (math.random(1, 99) >= 33) then
    --         return action.status.running
    --     else
    --         return action.status.success
    --     end
    -- end,bb, {}, {})

    -- -- 注册节点
    -- bt:add_child(se)
    -- bt:add_child(patrol)

    -- -- 执行相关行为
    -- for i = 1, 10 do
    --     bt:exec()
    --     if (not bt:is_running()) then
    --         bt:halt()
    --     end
    -- end

end

-- 子树模拟
function mytest.testB()

    -- 主干部分
    local mbb = blackboard:new()
    local mbt = fallback:new(mbb)
    local cbb = blackboard:new(mbb)

    cbb:redirect("mark", "target")

    -- 查找敌人
    local lookup = action:new(function(this)
        if (math.random(1, 99) <= 44) then
            print("lookup failure")
            return action.status.failure
        else
            print("lookup success")
            this:set("coordinate", {1, 5})
            return action.status.success
        end
    end, cbb, {}, { coordinate = '{coordinate}' })

    -- 攻击敌人
    local attack = action:new(function(this)
        local coordinate = this:get("coordinate")
        if (coordinate == nil) then
            print("attack error.")
        else
            print("attack ok", coordinate[1], coordinate[2])
            this:set("mark", "attach enemy.")
        end
        return action.status.success
    end, cbb, { coordinate = '{coordinate}' }, { mark = '{mark}' })

    -- 顺序节点
    local se = sequence:new(cbb, {}, {})
    se:add_child(lookup)
    se:add_child(attack)

    -- 自动巡逻
    local patrol = action:new(function(this)
        print("patrol", this:get("mark") or "unknown")
        if (math.random(1, 99) >= 33) then
            return action.status.running
        else
            this:set("mark", "reset")
            return action.status.success
        end
    end, mbb, {mark = "{target}"}, {mark = "{target}"})

    -- 注册节点
    mbt:add_child(se)
    mbt:add_child(patrol)

    -- 执行相关行为
    for i = 1, 20 do
        mbt:exec()
        if (not mbt:is_running()) then
            mbt:halt()
        end
    end

end

mytest:run()