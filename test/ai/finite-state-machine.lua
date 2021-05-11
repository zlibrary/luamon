-------------------------------------------------------------------------------
--- 'luamon.container.array'测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local FSM       = require 'luamon.ai.finite-state-machine'

-- 构建测试实例
local mytest = TestSuite.new()

-- 状态转换配置
local config = 
{
    -- 初始状态
    initial = 'solid',

    -- 事件处理（状态变更）
    states = 
    {
        -- 全体状态
        ['*'] = 
        {
            enter = function(event, source, target, ...)
                print(string.format("%s enter.", target))
            end,

            leave = function(event, source, target, ...)
                print(string.format("%s leave.", source))
            end,
        },

        -- 液体状态
        ['liquid'] = 
        {
            enter = function(event, source, target, ...)
                print(string.format("[liquid] : %s enter.", target))
            end,

            leave = function(event, source, target, ...)
                print(string.format("[liquid] : %s leave.", source))
            end,
        },
    },

    -- 事件处理（事件触发）
    events = 
    {
        -- 全体事件
        ['*'] = 
        {
            enter = function(event, source, target, ...)
                print(string.format("%s ~ %s:%s enter.", event, source, target))
            end,

            exec = function(event, source, target, ...)
                print(string.format("%s ~ %s:%s exec.", event, source, target))
            end,

            leave = function(event, source, target, ...)
                print(string.format("%s ~%s:%s leave.", event, source, target))
            end,
        },

        -- 蒸发事件
        ['vaporize'] = 
        {
            enter = function(event, source, target, ...)
                print(string.format("vaporize : %s:%s enter.", source, target))
            end,

            exec = function(event, source, target, ...)
                print(string.format("vaporize : %s:%s exec.", source, target))
            end,

            leave = function(event, source, target, ...)
                print(string.format("vaporize : %s:%s leave.", source, target))
            end,
        },
    },

    -- 转换配置
    transitions = 
    {
        { name = 'melt'    , from = 'solid' , to = 'luquid' },
        { name = 'freeze'  , from = 'luquid', to = 'solid'  },
        { name = 'vaporize', from = 'luquid', to = 'gas'    },
        { name = 'condense', from = 'gas'   , to = 'luquid' },
    },
}

-- 简单测试过程
function mytest.testA()

    print("\n")
    do
        local fsm = FSM.create(config)
        fsm:fire("melt"    )
        fsm:fire("freeze"  )
        fsm:fire("melt"    )
        fsm:fire("vaporize")
        fsm:fire("condense")
        fsm:fire("freeze"  )
        mytest:assert_eq(fsm:state(), "solid")
    end
end

mytest:run()
