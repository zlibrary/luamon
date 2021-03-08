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
    if __container_traits.static.categorys[category] then
        self.__category = category
    else
        error(string.format("'%s' isn't valid category.", tostring(category)))
    end
end

function __container_traits:is_sequential()
    return self.__category == "sequential"
end

function __container_traits:is_associated()
    return self.__category == "associated"
end

return __container_traits
