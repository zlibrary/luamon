-------------------------------------------------------------------------------
--- 复制 'Yet Another Class Implementation (version 1.2)' 的实现
-------------------------------------------------------------------------------

do  -- keep local things inside

    -- 'class'与其元信息间的映射
    local meta = {}
    setmetatable(meta, {__mode = "k"})

    -- 'table'复制（浅拷贝）
    local function duplicate(t)
        local rvalue = {}
        for k, v in pairs(t) do
            rvalue[k] = v
        end
        return rvalue
    end

    -- 类型实例生成
    local function newInstance(class, ...)
        -- -- 实例生成逻辑
        local function makeInstance(class, virtuals, child)
            local obj = duplicate(virtuals)
            meta[obj] = 
            {
                class = class, 
                super = 1,
                child = child,
            }
            if class:super() then
                meta[obj].super = makeInstance(class:super(), virtuals, obj)  -- 父类对象使用了子类的虚表（属性/函数覆盖）
            else
                meta[obj].super = nil
            end
            return setmetatable(obj, class.static)
        end
        -- 生成类型实例
        local obj = makeInstance(class, meta[class].virtuals)
        obj:init(...)
        return obj
    end

    -----------------------------------------------------------------
    --- 类型定义相关

    -- 指定虚方法（静态属性重载）
    local function makeVirtual(class, fname)
        local func = class.static[fname]
        if (func == nil) then
            func = function()
                error("Attempt to call an undefined abstract method '" .. fname .. "'")
            end
        end
        meta[class].virtuals[fname] = func
    end
            
    -- 类实例转换
    local function tryCast(class, inst)
        if inst.class == class then
            return inst
        end
        -- 向上转换
        local m = inst.super
        while (m ~= nil) do
            if m.class == class then
                return m
            end
            m = m.super
        end
        -- 向下转换
        local m = inst.child
        while (m ~= nil) do
            if m.class == class then
                return m
            end
            m = m.child
        end
        return nil
    end

    -- 类实例转换（无法转换则抛出异常）
    local function secureCast(class, inst)
        local castd = tryCast(class, inst)
        if castd then
            return castd
        else
            error("Failed to cast " .. tostring(inst) .. " to a " .. class:name())
        end
    end

    -- 实例类型检查
    local function classMade(class, inst)
        local ok, result = pcall(function()
            return (inst.class == class) or inst.class:inherits(class)
        end)
        return ok and result
    end

    -- 关键字集合（关键字为内部保护字段）
    local keywords = 
    {
        ['super'] = function(obj) return meta[obj].super end,
        ['child'] = function(obj) return meta[obj].child end,
        ['class'] = function(obj) return meta[obj].class end,
    }

    -- 子类构造逻辑
    local function subclass(base, name)
        if type(name) ~= "string" then
            name = "unnamed"
        end
        local class = {}
        local block = -- 继承元方法（这些方法不会自动向上查找）
        {
            __tostring = base.static.__tostring,
            __add      = base.static.__add,
            __sub      = base.static.__sub,
            __mul      = base.static.__mul,
            __div      = base.static.__div,
            __mod      = base.static.__mod,
            __pow      = base.static.__pow,
            __unm      = base.static.__unm,
            __idiv     = base.static.__idiv,
            __band     = base.static.__band,
            __bor      = base.static.__bor,
            __bxor     = base.static.__bxor,
            __bnot     = base.static.__bnox,
            __shl      = base.static.__shl,
            __shr      = base.static.__shr,
            __concat   = base.static.__concat,
            __len      = base.static.__len,
            __eq       = base.static.__eq,
            __lt       = base.static.__lt,
            __le       = base.static.__le,
            __call     = base.static.__call,
        }
        block.init = function(obj, ...)         -- 默认构造方法
            meta[obj].super:init(...)
        end
        block.__newindex = function(obj, k, v)  -- 更新实例属性（注意实例属性，不是类型属性）
            if (keywords[k] == nil) then
                if (meta[obj].super[k] == nil) then
                    rawset(obj, k, v)           -- 更新实例属性
                else
                    meta[obj].super[k] = v      -- 更新父类属性
                end
            else
                error("Prohobit to use keyword[" .. k .. "]")
            end
        end
        block.__index = function(obj, k)        -- 访问实例属性（实例属性优先，类型属性其次）
            if (keywords[k] ~= nil) then
                return keywords[k](obj)
            else
                local rvalue = block[k]
                if (rvalue ~= nil) then
                    return rvalue               -- 获取类型属性
                end
                -- 查找父类属性
                rvalue = meta[obj].super[k]
                if (type(rvalue) == "function") then
                    local super = meta[obj].super
                    local fn    = rvalue
                    return function(obj, ...)
                        return fn(super, ...)
                    end
                end
                return rvalue
            end
        end

        -- 保存虚表
        meta[class] = { virtuals = duplicate(meta[base].virtuals) }

        -- 绑定元表（类型各种功能通过元表实现）
        setmetatable(class,
        {
            __newindex = function(class, k, v)  -- 更新类型属性(包括虚属性)
                if (keywords[k] ~= nil) then
                    error("Prohibit to use keyword[" .. k .. "]")
                end
                block[k] = v
                if (meta[class].virtuals[k] ~= nil) then
                    meta[class].virtuals[k] = v
                end
            end,
            __index = function(class, k)        -- 获取类型属性
                local clazz = 
                {
                    static   = block,           -- '类型方法/静态属性'集合（实例对象元表）
                    made     = classMade,       -- 实例类型检查
                    new      = newInstance,     -- 实例创建接口
                    subclass = subclass,        -- 子类创建接口
                    virtual  = makeVirtual,     -- 虚属性定义
                    cast     = secureCast,      -- 实例类型转换（类似'C++'的类型强制转换）
                    trycast  = tryCast,         -- 实例类型转换（类似'C++'的类型强制转换）
                    super = function(class)
                        return base
                    end,
                    name = function(class)
                        return name
                    end,
                    inherits = function(class, other)
                        return (base == other or base:inherits(other))
                    end,
                }
                local rvalue = clazz[k]
                if rvalue then
                    return rvalue
                else
                    return base[k]
                end
            end,
            __call     = newInstance,
            __tostring = function() return name end,
        })
        return class
    end

    -----------------------------------------------------------------
    --- 基类'Object'

    local Object = {}

    -- 禁止修改
    local function newindex() error "May not modify the class 'Object'." end

    -- '类型方法/静态属性'集合
    local block = {}
    block.__newindex = newindex                 -- 禁止修改'类型方法/静态属性'
    block.__index = block                       -- 允许访问'类型方法/静态属性'
    block.__tostring = function(obj)            -- 返回对象描述
        return (obj.class:name())
    end
    block.init = function(obj, ...) end         -- 默认构造方法

    -- 类型元表
    local class =
    {
        static   = block,                       -- '类型方法/静态属性'集合（实例对象元表）
        made     = classMade,                   -- 实例类型检查
        new      = newInstance,                 -- 实例创建接口
        subclass = subclass,                    -- 子类创建接口
        cast     = secureCast,                  -- 实例类型转换（类似'C++'的类型强制转换）
        trycast  = tryCast,                     -- 实例类型转换（类似'C++'的类型强制转换）
    }
    function class.super(class)
        return nil
    end
    function class.name(class)
        return "Object"
    end
    function class.inherits(class, other)
        return false
    end

    -- 保存虚表
    meta[Object] = { virtuals = {} }

    -- 绑定元表（类型各种功能通过元表实现）
    setmetatable(Object,
    {
        __newindex = newindex,                  -- 禁止修改基类
        __index    = class,                     -- 访问基类属性
        __call     = newInstance,
        __tostring = function() return "Object" end,
    })

    -----------------------------------------------------------------
    --- 'newclass'方法（建议加入全局表使用）

    function newclass(name, base)
        base = base or Object
        return base:subclass(name)
    end

end
