-------------------------------------------------------------------------------
--- Provide a unified abstraction for the container.
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local __container_traits = newclass("__container_traits")

__container_traits.categorys = 
{
    ["associated"] = true,
    ["sequential"] = true,
}

function __container_traits:init(category)
    if not self.static.categorys[category] then
        error(string.format("'%s' isn't valid category.", tostring(category)))
    end
end

return __container_traits
