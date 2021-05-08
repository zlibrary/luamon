-------------------------------------------------------------------------------
--- 为容器提供统一的特性抽象描述（通过继承方式）
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local container_traits = newclass("luamon.container.traits.container_traits")

container_traits.categorys = 
{
    ["associated"] = true,
    ["sequential"] = true,
}

function container_traits:init(category)
    if container_traits.static.categorys[category] then
        self.__category = category
    else
        error(string.format("'%s' isn't valid category.", tostring(category)))
    end
end

function container_traits:is_sequential()
    return self.__category == "sequential"
end

function container_traits:is_associated()
    return self.__category == "associated"
end

return container_traits
