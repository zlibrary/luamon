-------------------------------------------------------------------------------
--- 事件构造器
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
--- 默认事件模型(仅提供接口)
local event = newclass("luamon.cache.evbuilder.event")

-- 等待事件通知
function event:wait()
end

-- 唤醒阻塞协程
function event:wakeup()
end

-------------------------------------------------------------------------------
local evbuilder = newclass("luamon.cache.evbuilder")

-- 数据移除通知
function evbuilder:build()
    return event:new()
end

return evbuilder
