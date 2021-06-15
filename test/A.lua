
require "luamon"

local function func(v)
    print(v)
end

local A = newclass("A")

function A:init(fn)
    self.fn = fn
end

function A:exec()
    print(self)
    self:fn()
end

local a = A:new(func)

a:exec()