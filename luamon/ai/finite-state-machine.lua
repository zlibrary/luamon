-------------------------------------------------------------------------------
--- 有限状态自动机，参考'javascript-state-machine'实现。
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 有限状态自动机
local finite_state_machine = newclass("luamon.ai.finite_state_machine")

local __wildcard = '*'

local function forward(context, event)
    local state = context:state()
    local to    = context.__transitions[state][event]
    if (to == nil) and (context.__transitions[__wildcard] ~= nil) then
        to = context.__transitions[__wildcard][event]
    end
    if (to ~= __wildcard) then
        return to
    else
        return state
    end
end

function finite_state_machine:init(transitions, states, events)
    self.__transitions = {}
    self.__states      = {}
    self.__events      = {}
    self.__state       = 'none'
    self.__transiting  = false
    -- 导入状态配置
    for name, data in pairs(states or {}) do
        if (type(name) ~= "string") or (name == "") then
            error(string.format("state's name[%s:%s] is invalid.", tostring(name), type(name)))
        end
        if (type(data) ~= "table") then
            error(string.format("state's data[%s:%s] is invalid.", tostring(data), type(data)))
        end
        local methods = {}
        for fname in pairs({enter = true, leave = true}) do
            local fn = data[fname]
            if (fn ~= nil) then
                if (type(fn) == "function") then
                    methods[fname] = fn
                else
                    error(string.format("state[%s]'s function[%s] is invalid.", name, fname))
                end
            end
        end
        self.__states[name] = methods
    end
    -- 导入事件配置
    for name, data in pairs(events or {}) do
        if (type(name) ~= "string") or (name == "") then
            error(string.format("event's name[%s:%s] is invalid.", tostring(name), type(name)))
        end
        if (type(data) ~= "table") then
            error(string.format("event's data[%s:%s] is invalid.", tostring(data), type(data)))
        end
        local methods = {}
        for fname in pairs({enter = true, leave = true, exec = true}) do
            local fn = data[fname]
            if (fn ~= nil) then
                if (type(fn) == "function") then
                    methods[fname] = fn
                else
                    error(string.format("event[%s]'s function[%s] is invalid.", name, fname))
                end
            end
        end
        self.__events[name] = methods
    end
    -- 导入转换配置
    for _, transition in ipairs(transitions) do
        local name = transition.name
        local from = transition.from
        local to   = transition.to
        if (type(name) ~= "string") or (name == "") or (name == __wildcard) then
            error(string.format("transition's name[%s] is invalid.", tostring(name)))
        end
        if (self.__events[name] == nil) then
            self.__events[name] = {}
        end
        if (type(from) ~= "string") or (from == "") then
            error(string.format("transition's from[%s] is invalid.", tostring(from)))
        end
        if (self.__states[from] == nil) and (from ~= __wildcard) then
            self.__states[from] = {}
        end
        if (type(to) ~= "function") and ((type(to) ~= "string") or (to == "")) then
            error(string.format("transition[%s:%s:%s] is invalid.", name, from, tostring(to)))
        end
        -- 记录转换配置
        local transits = self.__transitions[from]
        if (transits == nil) then
            transits = {}
            self.__transitions[from] = transits
        end
        if (transits[name] == nil) then
            transits[name] = to
        else
            error(string.format("transition[%s:%s:%s] is repeated.", name, from, tostring(to)))
        end
    end
end

function finite_state_machine:is_transiting()
    return self.__transiting
end

function finite_state_machine:state()
    return self.__state
end

function finite_state_machine:can(event)
    if self:is_transiting() then
        return false
    else
        local to = forward(self, event)
        if (to ~= nil) then
            return true
        else
            return false
        end
    end
end

function finite_state_machine:states()
    local rvalue = {}
    for name in pairs(self.__states) do
        table.insert(rvalue, name)
    end
    return rvalue
end

function finite_state_machine:events(state)
    local rvalue = {}
    if (state == nil) then
        for name in pairs(self.__events) do
            table.insert(rvalue, name)
        end
    else
        local transits = self.__transitions[state] or {}
        for name in pairs(transits) do
            table.insert(rvalue, name)
        end
    end
    return rvalue
end

function finite_state_machine:fire(event, ...)
    local source = self:state()
    local target = nil
    if (self:is_transiting() == true) then
        error(string.format("finite-state-machine[%s, %s] is transiting.", source, event))
    end
    target = forward(self, event)
    if type(target) == 'function' then
        target = target(self,...)
    end
    if (target == nil) then
        error(string.format("finite-state-machine[%s, %s] invalid event.", source, event))
    else
        if (self.__states[target] == nil) then
            self.__states[target] = {}
        end
    end
    -- 执行状态转换
    local retval     = true
    local transitnum = 10
    local transits   = 
    {
                               self.__events[__wildcard]['enter'],
                               self.__events[  event   ]['enter'],
        (source ~= target) and self.__states[__wildcard]['leave'],
        (source ~= target) and self.__states[  source  ]['leave'],
                               self.__events[  event   ]['exec' ],
        (source ~= target) and function() self.__state = target end,
        (source ~= target) and self.__states[__wildcard]['enter'],
        (source ~= target) and self.__states[  target  ]['leave'],
                               self.__events[__wildcard]['leave'],
                               self.__events[  event   ]['leave'],
    }
    self.__transiting = true
    for i = 1, transitnum do
        local fn = transits[i]
        if (fn ~= nil) then
            retval = fn(event, source, target, ...)
            if (retval == false) then
                break
            else
                retval = true
            end
        end
    end
    self.__transiting = false
    return retval
end

-------------------------------------------------------------------------------
--- 状态机生成模块
return
{
    create = function(config)
        -- 状态机生成参数检查
        local transitions = config.transitions
        local states      = config.states
        local events      = config.events
        local initial     = config.initial
        local context     = config.context
        if (initial == nil) or (initial == "") then
            initial = "none"
        end
        if (type(initial) ~= "string") then
            error(string.format("initial[%s:%s] is invalid.", tostring(initial), type(initial)))
        end
        if (context == nil) then
            context = {}
        end
        if (type(context) ~= "table") then
            error(string.format("context[%s:%s] is invalid.", tostring(context), type(context)))
        end
        if (states == nil) then
            states = {}
        end
        if (type(states) ~= "table") then
            error(string.format("states[%s:%s] is invalid.", tostring(states), type(states)))
        end
        if (events == nil) then
            events = {}
        end
        if (type(events) ~= "table") then
            error(string.format("events[%s:%s] is invalid.", tostring(events), type(events)))
        end
        if (type(transitions) ~= "table") then
            error(string.format("transitions[%s:%s] is invalid.", tostring(transitions), type(transitions)))
        end
        if (#transitions == 0) then
            error("transitions is empty.")
        end
        -- 构造初始转换配置
        if (initial ~= 'none') then
            table.insert(transitions, { name = 'init', from = 'none', to = initial })
        end
        -- 构造有限状态机对象
        local meta = { fsm = finite_state_machine:new(transitions, states, events) }
        meta.__index = function(_, k)
            return meta.fsm[k]
        end
        local obj = {}
        for k, v in pairs(context) do
            obj[k] = v
        end
        obj = setmetatable(obj, meta)
        -- 执行初始转换操作
        if (initial ~= 'none') then
            obj:fire('init')
        end
        return obj
    end
}
