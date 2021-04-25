-------------------------------------------------------------------------------
--- 缓存数据擦除接口描述
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local eraser = newclass("luamon.cache.eraser")

-- 数据移除通知
function eraser:exec(key, value)
    error("this function must overwrite!")
end

return eraser
