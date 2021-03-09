-------------------------------------------------------------------------------
--- 为迭代器提供统一的特性抽象描述（通过继承方式）
-------------------------------------------------------------------------------
require "luamon"

-------------------------------------------------------------------------------
local __iterator_tag_input         = newclass("__iterator_tag_input" )
local __iterator_tag_output        = newclass("__iterator_tag_output")
local __iterator_tag_forward       = newclass("__iterator_tag_forward"      , __iterator_tag_input        )
local __iterator_tag_bidirectional = newclass("__iterator_tag_bidirectional", __iterator_tag_forward      )
local __iterator_tag_random        = newclass("__iterator_tag_random"       , __iterator_tag_bidirectional)

-------------------------------------------------------------------------------
local iterator_traits = newclass("iterator_traits")

iterator_traits.categorys = 
{
    ['random-access'] = __iterator_tag_random,   
    ['input'        ] = __iterator_tag_input,
    ['output'       ] = __iterator_tag_output,
    ['forward'      ] = __iterator_tag_forward,
    ['bidirectional'] = __iterator_tag_bidirectional,
}

function iterator_traits:init(category)
    local c = iterator_traits.static.categorys[category]
    if (c ~= nil) then
        self.__category = c
    else
        error(string.format("'%s' isn't valid category.", tostring(category)))
    end
end

function iterator_traits:isa(category)
    local c = iterator_traits.static.categorys[category]
    if (c == nil) then
        return false
    else
        return (self.__category == c) or (self.__category:inherits(c))
    end
end

return iterator_traits
