-------------------------------------------------------------------------------
--- 有限状态机测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
local FSM       = require 'luamon.ai.finite-state-machine'

-- 构建测试实例
local mytest = TestSuite.new()

-- 'matter'状态迁移
local matter = 
{
    -- 初始状态
    initial = 'solid',

    -- 事件处理（状态变更）
    states = 
    {
        -- 全体状态
        ['*'] = 
        {
            enter = function(context, event, source, target, ...)
                mytest:assert_eq(context.state, target)
            end,

            leave = function(context, event, source, target, ...)
                mytest:assert_eq(context.state, source)
            end,
        },
    },

    -- 事件处理（事件触发）
    events = 
    {
        -- 全体事件
        ['*'] = 
        {
            enter = function(context, event, source, target, ...)
                mytest:assert_eq(context.state, source)
            end,

            exec = function(context, event, source, target, ...)
                context.state = target
            end,

            leave = function(context, event, source, target, ...)
                mytest:assert_eq(context.state, target)
            end,
        },
    },

    -- 转换配置
    transitions = 
    {
        { name = 'melt'    , from = 'solid' , to = 'liquid' },
        { name = 'freeze'  , from = 'liquid', to = 'solid'  },
        { name = 'vaporize', from = 'liquid', to = 'gas'    },
        { name = 'condense', from = 'gas'   , to = 'liquid' },
    },
}

-- 'wizard'状态迁移
local wizard = 
{
    -- 初始状态
    initial = 'A',

    -- 转换配置
    transitions = 
    {
        { name = 'step'  , from = 'A' , to = 'B' },
        { name = 'step'  , from = 'B' , to = 'C' },
        { name = 'step'  , from = 'C' , to = 'D' },
        { name = 'reset' , from = 'D' , to = 'A' },
        { name = 'reset' , from = 'C' , to = 'A' },
        { name = 'reset' , from = 'B' , to = 'A' },
    },
}

-- 'door'状态迁移
local door = 
{
    -- 初始状态
    initial = 'closed',

    -- 转换配置
    transitions = 
    {
        { name = 'open' , from = 'closed', to = 'open'   },
        { name = 'close', from = 'open'  , to = 'closed' },
    },
}
-- 字串格式检查（判断是否整数）
local integer = 
{
    initial = 'ready',

    -- 转换配置
    transitions = 
    {
        {
            name = 'input', 
            from = 'ready', 
            to   = function(context, ch)
                        if (ch == 43) or (ch == 45) or (ch >= 48 and ch <= 57) then
                            return 'number'
                        else
                            return 'failed'
                        end
                   end,
        },
        {
            name = 'input', 
            from = 'number', 
            to   = function(context, ch)
                        if (ch >= 48 and ch <= 57) then
                            return 'number'
                        else
                            return 'failed'
                        end
                   end,
        },
        { name = 'input' , from = 'failed', to = 'failed' },
    },
}

-- 简单测试过程
function mytest.testA()

    do
        local fsm = FSM.create({}, wizard)
        mytest:assert_eq(fsm.state(), "A")
        fsm.fire("step")
        mytest:assert_eq(fsm.state(), "B")
        fsm.fire("step")
        mytest:assert_eq(fsm.state(), "C")
        fsm.fire("step")
        mytest:assert_eq(fsm.state(), "D")
        fsm.fire("reset")
        mytest:assert_eq(fsm.state(), "A")
        fsm.fire("step")
        mytest:assert_eq(fsm.state(), "B")
        fsm.fire("step")
        mytest:assert_eq(fsm.state(), "C")
        fsm.fire("reset")
        mytest:assert_eq(fsm.state(), "A")
        fsm.fire("step")
        mytest:assert_eq(fsm.state(), "B")
        fsm.fire("reset")
        mytest:assert_eq(fsm.state(), "A")
    end

    do
        local fsm = FSM.create({}, door)
        mytest:assert_eq(fsm.state(), "closed")
        fsm.fire("open")
        mytest:assert_eq(fsm.state(), "open")
        fsm.fire("close")
        mytest:assert_eq(fsm.state(), "closed")

        mytest:assert_error(function()
            fsm.fire("step")
        end)
    end

    do
        local fsm = FSM.create({ state = 'none' }, matter)
        mytest:assert_eq(fsm.state(), "solid")
        fsm.fire("melt")
        mytest:assert_eq(fsm.state(), "liquid")
        fsm.fire("freeze")
        mytest:assert_eq(fsm.state(), "solid")
        fsm.fire("melt")
        fsm.fire("vaporize")
        mytest:assert_eq(fsm.state(), "gas")
        fsm.fire("condense")
        mytest:assert_eq(fsm.state(), "liquid")
        fsm.fire("freeze")
        mytest:assert_eq(fsm.state(), "solid")
    end

    -- 字串检查方法
    local function check(str)
        local fsm = FSM.create({}, integer)
        for i = 1, string.len(str) do
            fsm.fire("input", string.byte(string.sub(str, i, i)))
        end
        return fsm.state() == 'number'
    end

    do
        mytest:assert_true (check("123456"))
        mytest:assert_true (check("+12345"))
        mytest:assert_true (check("-12345"))
        mytest:assert_false(check("a12345"))
        mytest:assert_false(check("1a2345"))
        mytest:assert_false(check("12345a"))


    end

end

mytest:run()
