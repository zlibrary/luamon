-------------------------------------------------------------------------------
--- 行为树测试
-------------------------------------------------------------------------------
local TestSuite    = require 'luamon.ltest'
local BehaviorTree = require 'luamon.ai.behavior-tree'
local Command      = require 'luamon.ai.behavior-tree.actions.command'

-- 构建测试实例
local mytest = TestSuite.new()


-- 基础测试
function mytest.testA()

    -- 测试'fallback'节点
    do
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.fallback",
                children = 
                {
                    {
                        modname = "luamon.ai.behavior-tree.actions.always_failure",
                    },
                    {
                        modname = "luamon.ai.behavior-tree.actions.always_success",
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
        bt.exec()
        mytest:assert_true(bt.is_success())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.fallback",
                children = 
                {
                    {
                        modname = "luamon.ai.behavior-tree.actions.always_success",
                    },
                    {
                        modname = "luamon.ai.behavior-tree.actions.always_failure",
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
    end

    -- 测试'inverter'节点
    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.inverter",
                child   = 
                {
                    modname = "luamon.ai.behavior-tree.actions.always_success",
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.inverter",
                child   = 
                {
                    modname = "luamon.ai.behavior-tree.actions.always_failure",
                },
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.inverter",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.running
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_running())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_running())
    end

    -- 测试'force-failure'节点
    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.force_failure",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.running
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_running())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_running())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.force_failure",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.success
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.force_failure",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.failure
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
    end

    -- 测试'force-success'节点
    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.force_success",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.running
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_running())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_running())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.force_success",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.success
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
    end

    do
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.force_success",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            return Command.status.failure
                        end, bb, imports, exports)
                    end,
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
    end

    -- 测试'repeat'节点
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.repeat",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            count = count + 1
                            return Command.status.success
                        end, bb, imports, exports)
                    end,
                },
                imports = { decorator_repeat_times = 3 }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 3)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 6)
    end

    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.repeat",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            count = count + 1
                            if (count == 2) then
                                return Command.status.failure
                            else
                                return Command.status.success
                            end
                        end, bb, imports, exports)
                    end,
                },
                imports = { decorator_repeat_times = 3 }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 2)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 5)
    end

    -- 测试'retry'节点
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.retry",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            count = count + 1
                            return Command.status.failure
                        end, bb, imports, exports)
                    end,
                },
                imports = { decorator_retry_times = 3 }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 3)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 6)
    end

    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.retry",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            count = count + 1
                            if (count == 2) then
                                return Command.status.success
                            else
                                return Command.status.failure
                            end
                        end, bb, imports, exports)
                    end,
                },
                imports = { decorator_retry_times = 3 }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 2)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 5)
    end

    -- 测试'delay'节点
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname = "luamon.ai.behavior-tree.decorators.delay",
                child   = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            count = count + 1
                            return Command.status.success
                        end, bb, imports, exports)
                    end,
                },
                imports = { decorator_delay_times = 3 }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 0)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 0)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 0)
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 1)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 1)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 1)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 1)
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 2)
    end

    -- 测试'sequence'节点
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.sequence",
                children = 
                {
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.succcess
                            end, bb, imports, exports)
                        end
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 1)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 2)
    end
    
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.sequence",
                children = 
                {
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.success
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 2)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 4)
    end
    
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.sequence",
                children = 
                {
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                if (count == 1) then
                                    return Command.status.running
                                else
                                    return Command.status.success
                                end
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 1)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 3)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 5)
    end

    -- 测试'parallel'节点
    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.parallel",
                imports  = {parallel_success_threshold = 2, parallel_failure_threshold = 2},
                children = 
                {
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.success
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.success
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 3)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 6)
    end

    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.parallel",
                imports  = {parallel_success_threshold = 2, parallel_failure_threshold = 2},
                children = 
                {
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.success
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 2)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 4)
    end

    do
        local count   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.parallel",
                imports  = {parallel_success_threshold = 2, parallel_failure_threshold = 2},
                children = 
                {
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                if (count == 1) then
                                    return Command.status.running
                                else
                                    return Command.status.failure
                                end
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.success
                            end, bb, imports, exports)
                        end
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                return Command.status.failure
                            end, bb, imports, exports)
                        end
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        bt.exec()
        mytest:assert_true(bt.is_running())
        mytest:assert_eq(count, 1)
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 3)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        bt.exec()
        mytest:assert_true(bt.is_failure())
        mytest:assert_eq(count, 5)
    end
end


-- -- 巡逻模拟
-- function mytest.testC()

--     local mconfig = 
--     {
--         maintree = 
--         {
--             modname  = "luamon.ai.behavior-tree.controls.fallback",
--             children = 
--             {
--                 -- 搜查
--                 {
--                     modname  = "luamon.ai.behavior-tree.controls.sequence",
--                     children = 
--                     {
--                         -- 搜查
--                         {
--                             modname = function(bb, imports, exports)
--                                 return SimpleAction:new(function(this)
--                                     if (math.random(1, 99) <= 55) then
--                                         print("lookup failure")
--                                         return SimpleAction.status.failure
--                                     else
--                                         print("lookup success")
--                                         this:set("coordinate", {1, 5})
--                                         return SimpleAction.status.success
--                                     end
--                                 end, bb, imports, exports)
--                             end,
--                             exports = {coordinate = '{coordinate}'},
--                         },
--                         -- 攻击
--                         {
--                             modname = function(bb, imports, exports)
--                                 return SimpleAction:new(function(this)
--                                     local coordinate = this:get("coordinate")
--                                     if (coordinate == nil) then
--                                         print("attack error.")
--                                     else
--                                         print("attack ok", coordinate[1], coordinate[2])
--                                     end
--                                     return SimpleAction.status.success
--                                 end, bb, imports, exports)
--                             end,
--                             imports = {coordinate = '{coordinate}'},
--                         },
--                     },
--                 },
--                 -- 巡逻
--                 {
--                     modname = function(bb, imports, exports)
--                         return SimpleAction:new(function(this)
--                             print("patrol")
--                             if (math.random(1, 99) >= 33) then
--                                 return SimpleAction.status.running
--                             else
--                                 return SimpleAction.status.success
--                             end
--                         end, bb, imports, exports)
--                     end,
--                 },
--             },
--         },
--     }

--     local bt = BehaviorTree.create(mconfig)
--     for i = 1, 10 do
--         print("\n-------------------", i)
--         bt.exec()
--         if (not bt.is_running()) then
--             bt.halt()
--         end
--     end


--     -- local bb = blackboard:new()
--     -- local bt = fallback:new(bb)

--     -- -- 查找敌人
--     -- local lookup = action:new(function(this)
--     --     if (math.random(1, 99) <= 55) then
--     --         print("lookup failure")
--     --         return action.status.failure
--     --     else
--     --         print("lookup success")
--     --         this:set("coordinate", {1, 5})
--     --         return action.status.success
--     --     end
--     -- end, bb, {}, { coordinate = '{coordinate}' })

--     -- -- 攻击敌人
--     -- local attack = action:new(function(this)
--     --     local coordinate = this:get("coordinate")
--     --     if (coordinate == nil) then
--     --         print("attack error.")
--     --     else
--     --         print("attack ok", coordinate[1], coordinate[2])
--     --     end
--     --     return action.status.success
--     -- end, bb, { coordinate = '{coordinate}' }, {})

--     -- -- 顺序节点
--     -- local se = sequence:new(bb, {}, {})
--     -- se:add_child(lookup)
--     -- se:add_child(attack)

--     -- -- 自动巡逻
--     -- local patrol = action:new(function()
--     --     print("patrol")
--     --     if (math.random(1, 99) >= 33) then
--     --         return action.status.running
--     --     else
--     --         return action.status.success
--     --     end
--     -- end,bb, {}, {})

--     -- -- 注册节点
--     -- bt:add_child(se)
--     -- bt:add_child(patrol)

--     -- -- 执行相关行为
--     -- for i = 1, 10 do
--     --     bt:exec()
--     --     if (not bt:is_running()) then
--     --         bt:halt()
--     --     end
--     -- end

-- end

-- -- 子树模拟
-- -- function mytest.testB()

-- --     -- 主干部分
-- --     local mbb = blackboard:new()
-- --     local mbt = fallback:new(mbb)
-- --     local cbb = blackboard:new(mbb)

-- --     cbb:redirect("mark", "target")

-- --     -- 查找敌人
-- --     local lookup = action:new(function(this)
-- --         if (math.random(1, 99) <= 44) then
-- --             print("lookup failure")
-- --             return action.status.failure
-- --         else
-- --             print("lookup success")
-- --             this:set("coordinate", {1, 5})
-- --             return action.status.success
-- --         end
-- --     end, cbb, {}, { coordinate = '{coordinate}' })

-- --     -- 攻击敌人
-- --     local attack = action:new(function(this)
-- --         local coordinate = this:get("coordinate")
-- --         if (coordinate == nil) then
-- --             print("attack error.")
-- --         else
-- --             print("attack ok", coordinate[1], coordinate[2])
-- --             this:set("mark", "attach enemy.")
-- --         end
-- --         return action.status.success
-- --     end, cbb, { coordinate = '{coordinate}' }, { mark = '{mark}' })

-- --     -- 顺序节点
-- --     local se = sequence:new(cbb, {}, {})
-- --     se:add_child(lookup)
-- --     se:add_child(attack)

-- --     -- 自动巡逻
-- --     local patrol = action:new(function(this)
-- --         print("patrol", this:get("mark") or "unknown")
-- --         if (math.random(1, 99) >= 33) then
-- --             return action.status.running
-- --         else
-- --             this:set("mark", "reset")
-- --             return action.status.success
-- --         end
-- --     end, mbb, {mark = "{target}"}, {mark = "{target}"})

-- --     -- 注册节点
-- --     mbt:add_child(se)
-- --     mbt:add_child(patrol)

-- --     -- 执行相关行为
-- --     for i = 1, 20 do
-- --         mbt:exec()
-- --         if (not mbt:is_running()) then
-- --             mbt:halt()
-- --         end
-- --     end

-- -- end

mytest:run()