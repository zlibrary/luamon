-------------------------------------------------------------------------------
--- 行为树基础节点类型
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local treenode = newclass("luamon.ai.behavior-tree.treenode")

-- 节点类型枚举
rawset(treenode, "category", 
{
    action    = 1,
    condition = 2,
    control   = 3,
    decorator = 4,
    subtree   = 5,
})

-- 节点状态枚举
rawset(treenode, "status",
{
    idle      = 0,
    running   = 1,
    success   = 2,
    failure   = 3,
})

-- 构造节点对象
-- 1. 黑板对象
-- 2. 输入映射
-- 3. 输出映射
function treenode:init(blackboard, imports, exports)
    self.__observers  = {}
    self.__status     = treenode.status.idle
    self.__imports    = imports
    self.__exports    = exports
    self.__blackboard = blackboard
end

function treenode:exec()
    local status = self:tick()
    return self:status(status)
end

function treenode:tick()
    error("this function must overwrite!")
end

function treenode:halt()
    error("this function must overwrite!")
end

function treenode:type()
    error("this function must overwrite!")
end

function treenode:is_running()
    return self.__status == treenode.status.running
end

function treenode:is_halt()
    return self.__status == treenode.status.idle
end

function treenode:is_success()
    return self.__status == treenode.status.success
end

function treenode:is_failure()
    return self.__status == treenode.status.failure
end

function treenode:get_status()
    return self.__status
end

function treenode:set_status(newstatus)
    if ((newstatus >= treenode.status.idle) and (newstatus <= treenode.status.failure)) then
        if (self.__status ~= newstatus) then
            local ostatus = self.__status
            self.__status = newstatus
            for _, cb in pairs(self.__observers) do
                pcall(cb, self, ostatus, newstatus)
            end
        end
        return slef.__status
    else
        error(string.format("treenode:set_status(%s) : status is invalid.", newstatus))
    end
end

function treenode:subscribe(callback)
    if (type(callback) == "function") then
        table.insert(self.__observers, callback)
    else
        error("treenode.subscribe : callback not a function.")
    end
end

local function strip_blackboard_pointer(s)
    if (type(s) ~= 'string') then
        return nil
    else
        return string.match(s, "^[$]?{(.+)}$")
    end
end

function treenode:get(key)
    local k = self.__imports[key]
    if (k == nil) then
        error(string.format("treenode:get(%s) : imports not contain the key.", key))
    end
    if (k == "=") then
        k = "{" .. key .. "}"
    end
    local remapped = strip_blackboard_pointer(k)
    if (remapped == nil) then
        return k
    else
        return self.__blackboard:get(remapped)
    end
end

function treenode:set(key, val)
    local k = self.__exports[key]
    if (k == nil) then
        error(string.format("treenode:set(%s) : exports not contain the key.", key))
    end
    if (k == "=") then
        k = "{" .. key .. "}"
    end
    local remapped = strip_blackboard_pointer(k)
    if (remapped ~= nil) then
        self.__blackboard:set(remapped, val)
    else
        error(string.format("treenode:set(%s) : cannot change the constants.", key))
    end
end

return treenode
