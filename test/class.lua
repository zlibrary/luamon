-------------------------------------------------------------------------------
--- 针对'luamon.class'的基础测试
-------------------------------------------------------------------------------
local TestSuite = require 'luamon.ltest'
require "luamon.class"

-- 构建测试实例
local mytest = TestSuite.new()

function mytest.testA()

    -- 类型定义
    local LivingBeing = newclass('LivingBeing')
    local Animal = newclass('Animal', LivingBeing)
    function Animal:init(name, age)
        self.name = name
        self.age  = age
    end
    function Animal:eat()
        return 'An animal is eating...'
    end
    function Animal:speak()
        return 'An animal is speaking...'
    end
    function Animal:__tostring()
        return 'A Animal called ' .. self.name .. ' and aged ' .. self.age
    end

    local Dog = newclass('Dog', Animal)
    function Dog:init(name, age, master)
        self.super:init(name, age)
        self.master = master
    end
    function Dog:eat()
        return 'An dog is eating...'
    end
    function Dog:speak()
        return 'Wah, wah!'
    end

    local Cat = newclass('Cat', Animal)
    function Cat:init(name, age)
        self.super:init(name, age)
    end
    function Cat:speak()
        return 'Meoow!'
    end

    local Human = Animal:subclass("Human")
    function Human:init(name, age, city)
        self.super:init(name, age)
        self.city = city
    end
    function Human:speak()
        return 'Hello!'
    end
    function Human:__tostring()
        return 'A human called ' .. self.name .. ' and aged ' .. self.age .. ', living at ' .. self.city
    end

    -- 类型名称
    mytest:assert_eq(LivingBeing:name(), 'LivingBeing')
    mytest:assert_eq(Animal:name(), 'Animal')
    mytest:assert_eq(Dog:name(), 'Dog')
    mytest:assert_eq(Cat:name(), 'Cat')
    mytest:assert_eq(Human:name(), 'Human')

    -- 父类检查
    mytest:assert_eq(Animal:super(), LivingBeing)
    mytest:assert_eq(Dog:super(), Animal)
    mytest:assert_eq(Cat:super(), Animal)
    mytest:assert_eq(Human:super(), Animal)
    mytest:assert_eq(Dog:super(), Cat:super())

    -- 继承关系
    mytest:assert_true(Animal:inherits(LivingBeing))
    mytest:assert_true(Dog:inherits(LivingBeing))
    mytest:assert_true(Cat:inherits(LivingBeing))
    mytest:assert_true(Dog:inherits(Animal))
    mytest:assert_true(Cat:inherits(Animal))

    mytest:assert_false(Animal:inherits(Animal))
    mytest:assert_false(Animal:inherits(Dog))
    mytest:assert_false(Animal:inherits(Cat))
    mytest:assert_false(Cat:inherits(Cat))
    mytest:assert_false(Dog:inherits(Cat))
    mytest:assert_false(Dog:inherits(Human))
    mytest:assert_false(LivingBeing:inherits(Human))

    -- 构建实例
    local Robert   = Human:new("Robert", 35, "London")
    local Garfield = Cat:new("Garfield", 18)
    local Mary     = Human:new("Mary", 20, "New York")
    local Albert   = Dog:new("Albert", 10, Mary)

    -- 实例检查
    mytest:assert_eq(Robert.name, 'Robert')
    mytest:assert_eq(Robert.age , 35)
    mytest:assert_eq(Garfield.name  , 'Garfield')
    mytest:assert_eq(Garfield.age   , 18)
    mytest:assert_eq(Garfield.master, nil)
    mytest:assert_eq(Mary.name, 'Mary')
    mytest:assert_eq(Mary.age , 20)
    mytest:assert_eq(Albert.name  , 'Albert')
    mytest:assert_eq(Albert.age   , 10)
    mytest:assert_eq(Albert.Master, Mery)

    -- 类型检查
    mytest:assert_true(LivingBeing:made(Robert))
    mytest:assert_true(LivingBeing:made(Garfield))
    mytest:assert_true(Animal:made(Robert))
    mytest:assert_true(Animal:made(Garfield))
    mytest:assert_true(Human:made(Robert))
    mytest:assert_true(Cat:made(Garfield))
    mytest:assert_false(Dog:made(Garfield))
    mytest:assert_false(Human:made(Garfield))

    -- 类型转换
    mytest:assert_not_error(function() Animal:cast(Robert) end)
    mytest:assert_not_error(function() LivingBeing:cast(Robert) end)
    mytest:assert_not_error(function() LivingBeing:cast(Garfield) end)
    mytest:assert_error(function() Cat:cast(Robert) end)
    mytest:assert_error(function() Cat:cast({}) end)

    -- 函数检查
    mytest:assert_eq(Robert:eat(), 'An animal is eating...')
    mytest:assert_eq(Robert:speak(), 'Hello!')
    mytest:assert_eq(Animal:cast(Robert):speak(), 'An animal is speaking...')
end

-- 虚函数测试
function mytest.testB()

    -- 类型定义
    local A = newclass('A')
    function A:F1()
        return 'A:F1'
    end
    function A:F2()
        return 'A:F2'
    end
    A:virtual('F1')
    A.value = 0

    local B = A:subclass('B')
    function B:F1()
        return 'B:F1'
    end
    function B:F2()
        return 'B:F2'
    end

    local C = A:subclass('C')
    function C:F1()
        return 'C:F1'
    end
    function C:F2()
        return 'C:F2'
    end

    -- 虚函数测试
    local a = A:new()
    local b = B:new()
    local c = C:new()

    mytest:assert_eq(a:F1(), "A:F1")
    mytest:assert_eq(a:F2(), "A:F2")
    mytest:assert_eq(b:F1(), "B:F1")
    mytest:assert_eq(b:F2(), "B:F2")
    mytest:assert_eq(c:F1(), "C:F1")
    mytest:assert_eq(c:F2(), "C:F2")

    mytest:assert_eq(A:cast(b):F1(), "B:F1")
    mytest:assert_eq(A:cast(b):F2(), "A:F2")
    mytest:assert_eq(A:cast(c):F1(), "C:F1")
    mytest:assert_eq(A:cast(c):F2(), "A:F2")

    -- 静态数据检查
    mytest:assert_eq(a.value, 0)
    mytest:assert_eq(b.value, 0)
    mytest:assert_eq(c.value, 0)

    A.value = 1
    mytest:assert_eq(a.value, 1)
    mytest:assert_eq(b.value, 1)
    mytest:assert_eq(c.value, 1)
end

-- 私有数据测试（通过外部表'mtab'实现）
function mytest.testC()

    -- 外部数表
    local mtab = {}

    -- 类型定义
    local A = newclass('A')

    function A:init()
        mtab[self] = {}
    end

    function A:set(k, v)
        mtab[self][k] = v
    end

    function A:get(k)
        return mtab[self][k]
    end

    -- 构建实例
    local a = A:new()
    local b = A:new()

    -- 类型测试
    mytest:assert_eq(a.class, A)
    mytest:assert_true(A:made(a))

    -- 操作测试
    for i = 1, 10 do
        a:set(i, 'a' .. i)
        b:set(i, 'b' .. i)
    end

    for i = 1, 10 do
        mytest:assert_ne(a:get(i), b:get(i))
    end

    for i = 1, 10 do
        mytest:assert_eq(a:get(i), 'a' .. i)
    end

end

function mytest.testD()

    do
        -- 类型定义
        local A = newclass('A')

        function A:init()
            self.v = 1
        end

        function A:set()
        end

        function A:get()
        end

        local B = A:subclass('B')

        for i = 1, 1000000 do

            -- local a = {}
            -- a.__index__ = 1
            -- a.__class__ = 2

            local a = B:new()

        end

    end
end

mytest:run()
