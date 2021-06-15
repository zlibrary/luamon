-------------------------------------------------------------------------------
--- 黑板, 为行为树提供数据交换机制
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local blackboard = newclass("luamon.ai.behavior-tree.blackboard")

function blackboard:init(parent)
    self.remapping = {}
    self.cache     = {}
    self.parent    = parent
end

function blackboard:get(key)
    if self.parent then
        local k = self.remapping[key]
        if (k ~= nil) then
            return self.parent:get(k)
        end
    end
    return self.cache[key]
end

function blackboard:set(key, value)
    if self.parent then
        local k = self.remapping[key]
        if (k ~= nil) then
            self.parent:set(k, value)
            return
        end
    end
    self.cache[key] = value
end

function blackboard:redirect(internal, external)
    self.remapping[internal] = external
end

return blackboard
