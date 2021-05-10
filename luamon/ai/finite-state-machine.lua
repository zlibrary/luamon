-------------------------------------------------------------------------------
--- 有限状态自动机，参考'javascript-state-machine'实现。
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 有限状态自动机（内部）
local finite_state_machine = newclass("luamon.ai.finite_state_machine")

local __wildcard = '*'

local function forward(context, event)
    local state = context:state()
    local to    = context.__transtions[state][event]
    if (to == nil) then
        to = context.__transtions[__wildcard][event]
    end
    if (to ~= __wildcard) then
        return to
    else
        return state
    end
end

function finite_state_machine:init(states, events, transitions)
    self.transitions = {}
    self.states      = {}
    self.transits    = {}
    self.state       = 'none'
    self.transiting  = false
    -- 导入状态配置
    for name, data in pairs(states) do
        if (type(name) ~= "string") or (name == "") or (name == __wildcard) then
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
        self.states[name] = methods
    end
    -- 导入事件配置
    for name, data in pairs(events) do
        if (type(name) ~= "string") or (name == "") or (name == __wildcard) then
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
        self.transits[name] = methods
    end
    -- 导入转换配置
    for _, transition in ipairs(transitions) do
        local name = transtion.name
        local from = transtion.from
        local to   = transtion.to
        if (type(name) ~= "string") or (name == "") or (name == __wildcard) then
            error(string.format("transition's name[%s:%s] is invalid.", tostring(name), type(name)))
        end
        if (type(from) ~= "string") or (from == "") then
            error(string.format("transition's from[%s:%s] is invalid.", tostring(from), type(from)))
        end
        if (self.states[from] == nil) and (from ~= __wildcard) then
            self.states[from] = {}
        end
        if (type(to) == "function") or ((type(to) == "string") and (to ~= "")) then
            -- 记录转换配置
            local events = self.transitions[from]
            if (events == nil) then
                events = {}
                self.transitions[from] = events
            end
            if (events[name] == nil) then
                events[name] = to
            else
                error(string.format("transition[%s:%s] is repeated.", from, name))
            end
        else
            error(string.format("transition's to[%s:%s] is invalid.", tostring(to), type(to)))
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
    for state in pairs(self.__transtions) do
        table.insert(rvalue, state)
    end
    return rvalue
end

function finite_state_machine:events(state)
end

function finite_state_machine:fire(name, ...)
    local source  = self:state()
    local target  = nil
    local transit = nil
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


end




