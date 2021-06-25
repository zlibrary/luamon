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

-- 节点通信
function mytest.testB()

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
                                this:set("v1", 1)
                                this:set("v2", 2)
                                return Command.status.success
                            end, bb, imports, exports)
                        end,
                        exports = { v1 = "{v1}", v2 = "{v2}" }
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                local v1 = this:get("p1")
                                local v2 = this:get("p2")
                                assert(v1 == 1)
                                assert(v2 == 2)
                                this:set("p1", v1 + 1)
                                this:set("p2", v2 + 1)
                                return Command.status.success
                            end, bb, imports, exports)
                        end,
                        imports = { p1 = "{v1}", p2 = "{v2}" },
                        exports = { p1 = "{p1}", p2 = "{p2}" },
                    },
                    {
                        modname = function(bb, imports, exports)
                            return Command:new(function(this)
                                count = count + 1
                                local v1 = this:get("k1")
                                local v2 = this:get("k2")
                                local p1 = this:get("k3")
                                local p2 = this:get("k4")
                                assert(v1 == 1)
                                assert(v2 == 2)
                                assert(p1 == 2)
                                assert(p2 == 3)
                                return Command.status.success
                            end, bb, imports, exports)
                        end,
                        imports = { k1 = "{v1}", k2 = "{v2}", k3 = "{p1}", k4 = "{p2}" },
                    },
                }
            }
        }
        local bt = BehaviorTree.create(mconfig)
        mytest:assert_not_error(function() bt.exec() end)
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 3)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        mytest:assert_not_error(function() bt.exec() end)
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 6)
    end

end

-- 子树合成
function mytest.testC()

    do
        local count   = 0
        local value   = 0
        local mconfig = 
        {
            maintree = 
            {
                modname  = "luamon.ai.behavior-tree.controls.sequence",
                children = 
                {
                    {
                        modname = "subtree",
                        mapping = {v1 = "v1", v2 = "v2"},
                        subtree = "T1",
                    },
                    {
                        modname = "subtree",
                        subtree = "T2",
                    },
                    {
                        modname = "subtree",
                        mapping = {v1 = "v1", v2 = "v2"},
                        subtree = "T1",
                    },
                }
            },
            subtrees = 
            {
                T1 = 
                {
                    modname  = "luamon.ai.behavior-tree.controls.sequence",
                    children = 
                    {
                        {
                            modname = function(bb, imports, exports)
                                return Command:new(function(this)
                                    count = count + 1
                                    local v1 = this:get("p1")
                                    local v2 = this:get("p2")
                                    if (v1 == nil) then
                                        v1 = 0
                                    end
                                    if (v2 == nil) then
                                        v2 = 0
                                    end
                                    value = value + v1 + v2
                                    this:set("p1", v1)
                                    this:set("p2", v2)
                                    return Command.status.success
                                end, bb, imports, exports)
                            end,
                            imports = { p1 = "{v1}", p2 = "{v2}" },
                            exports = { p1 = "{p1}", p2 = "{p2}" },
                        },
                        {
                            modname = function(bb, imports, exports)
                                return Command:new(function(this)
                                    count = count + 1
                                    local v1 = this:get("p1") + 1
                                    local v2 = this:get("p2") + 1
                                    value = value + v1 + v2
                                    this:set("p1", v1)
                                    this:set("p2", v2)
                                    return Command.status.success
                                end, bb, imports, exports)
                            end,
                            imports = { p1 = "{p1}", p2 = "{p2}" },
                            exports = { p1 = "{v1}", p2 = "{v2}" },
                        },
                    }
                },
                T2 = 
                {
                    modname = function(bb, imports, exports)
                        return Command:new(function(this)
                            count = count + 1
                            local v1 = this:get("v1")
                            local v2 = this:get("v2")
                            assert(v1 == nil)
                            assert(v2 == nil)
                            return Command.status.success
                        end, bb, imports, exports)
                    end,
                    imports = { v1 = "{v1}", v2 = "{v2}" },
                }
            },
        }
        local bt = BehaviorTree.create(mconfig)
        mytest:assert_not_error(function() bt.exec() end)
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 5)
        mytest:assert_eq(value, 8)
        bt.halt()
        mytest:assert_true(bt.is_halt())
        mytest:assert_not_error(function() bt.exec() end)
        mytest:assert_true(bt.is_success())
        mytest:assert_eq(count, 10)
        mytest:assert_eq(value, 32)
    end

end

mytest:run()