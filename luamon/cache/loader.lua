-------------------------------------------------------------------------------
--- 缓存数据加载接口描述
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local loader = newclass("luamon.cache.loader")

-- 数据加载通知
function loader:load(key)
    error("this function must overwrite!")
end

return loader
