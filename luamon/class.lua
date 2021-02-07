-------------------------------------------------------------------------------
--- 复制 'Yet Another Class Implementation (version 1.2)' 的实现
-------------------------------------------------------------------------------

do  -- keep local things inside

    -- associations between an object an its meta-informations
    -- e.g its class, its "lower" object (if any), ...
    local meta = {}
    setmetatable(meta, {__mode = "k"})

    -- 'table'复制（浅拷贝）
    local function duplicate(t)
        rvalue = {}
        for k, v in pairs(t) do
            rvalue[k] = v
        end
        return rvalue
    end

    -- 类型实例生成
    local function newInstance(class, ...)
        -- 实例生成逻辑
        local function makeInstance(class, virtuals)
            local inst = duplicate(virtuals)
            meta[inst] = {obj = inst, class = class}
            if class:super() then
                inst.super = makeInstance(class:super(), virtuals)  -- 父类对象使用了子类的虚表（属性/函数覆盖）
                meta[inst].super = meta[inst.super]
                meta[inst.super].child = meta[inst]
            else
                inst.super = {}
            end
            return setmetatable(inst, class.static)
        end
        -- 生成类型实例
        local inst = makeInstance(class, meta[class].virtuals)
        inst:init(...)
        return inst
    end

    -----------------------------------------------------------------
    --- 类型定义相关

    -- 指定虚方法（？静态属性重载？）
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
        local m = meta[inst]
        if m.class == class then
            return inst
        end
        -- 向下转换
        local m = meta[inst].child
        while (m ~= nil) do
            if m.class == class then
                return m.obj
            end
            m = m.child
        end
        -- 向上转换
        local m = meta[inst].super
        while (m ~= nil) do
            if m.class == class then
                return m.obj
            end
            return m.super
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
        if (mate[inst] == nil) then
            return false
        else
            return (tryCast(class, inst) ~= nil)
        end
    end

    -- 子类构造逻辑
    local function subclass(base, name)
        if type(name) ~= "string" then
            name = "unnamed"
        end
        local clazz = {}
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
        block.class = function() return clazz end
        block.init = function(inst, ...) inst.super:init(...) end
        block.__newindex = function(inst, k, v)
            if (inst.super[k] ~= nil) then
                inst.super[k] = v   -- 优先更新父类
            else
                rawset(inst, k, v)  -- 创建新字段
            end
        end
        block.__index = function(inst, k)
            local rvalue = block[k]
            if (rvalue ~= nil) then
                return rvalue
            end
            -- 查找父类
            rvalue = inst.super[key]
            if (type(rvalue) == "function") then
                -- 深度嵌套(深度较大的情况下)
                local object = inst.super
                local fn     = rvalue
                return function(inst, ...)
                    return vn(object, ...)
                end
            end
            return rvalue
        end
        local class = 
        {
            static   = block,
            made     = classMade,           
            new      = newInstance,
            subclass = subclass,
            virtual  = makeVirtual,
            cast     = secureCast,
            trycast  = tryCast,
        }
        function class.name(class)
            return name
        end
        function class.super(class)
            return base
        end
        function class.inherits(class, other)
            return (base == other or base:inherits(other))
        end

        -- 保存虚表
        meta[clazz] = {virtuals = duplicate(meta[base].virtuals)}

        -- 绑定元表
        setmetatable(clazz, 
        {
            __newindex = function(class, k, v)
                block[k] = v
                if (meta[class].virtuals[k] ~= nil) then
                    meta[class].virtuals[k] = v
                end
            end,
            __index = class,
            __tostring = function() return name end,
            __call = newInstance,
        })
        return clazz
    end

    -- 类结构描述（类本身是一个空表[构建后可定义方法/属性]，通过元表实现继承）
    -- 1. __newindex : 提供'方法'/'属性'的定义功能
    -- 2. __index    :
    --    {
    --      static   : 类型'方法'/'属性'集合
    --      made     : 类型检查接口
    --      new      : 实例创建接口
    --      subclass : 子类定义接口
    --      virtual  : 定义虚方法
    --      cast     : 类型转换接口
    --      trycast  : 类型装欢接口
    --      name     : 获取类型名称
    --      super    : 获取父类型
    --      inherits : 继承检查接口
    --    }

    -----------------------------------------------------------------
    --- 基类'Object'

    local Object = {}

    -- 禁止修改
    local function newindex() error "May not modify the class 'Object'." end

    -- 公共属性（静态属性以及类型方法集合）
    local block = {} 
    block.__index = block
    block.__newindex = newindex
    function block:init(inst, ...) end 
    function block.class() return Object end
    function block.__tostring(inst) return ("a " .. inst:class():name()) end

    -- 类型定义（提供了类型相关的操作方法）
    local class = 
    {
        static   = block,
        made     = classMade,           
        new      = newInstance,
        subclass = subclass,
        cast     = secureCast,
        trycast  = tryCast,
    }
    function class.name(class)
        return "Object"
    end
    function class.super(class)
        return nil
    end
    function inherits(class, other)
        return false
    end

    -- 保存虚表
    meta[Object] = {virtuals = {}}

    -- 绑定元表
    setmetatable(Object, 
    {
        __newindex = newindex,
        __index = class,
        __tostring = function() return "Object" end,
        __call = newInstance,
    })

    -----------------------------------------------------------------
    --- 'newclass'方法（建议加入全局表使用）

    function newclass(name, base)
        base = base or Object
        return base:subclass(name)
    end

end






local __TABLE_MAX_DEPTH = 9

local function __gtab(depth)
    local retval = ""
    for i = 1, depth do
        retval = retval .. "\t"
    end
    return retval
end

local function __dump(t, depth, collect)
    local retval = ""
    if type(t) == "table" then
        if (collect[t] ~= nil) then
            retval = retval .. "table[...]"
        else
            collect[t] = true
            depth = depth + 1
            if depth > __TABLE_MAX_DEPTH then
                retval = retval .. "..."
            else
                retval = retval .. "{\n"
                for k, v in pairs(t) do
                    retval = retval .. __gtab(depth) .. tostring(k) .. " = " .. __dump(v, depth, collect) .. ",\n"
                end
                retval = retval .. __gtab(depth - 1) .. "}"
            end
        end
    else
        retval = retval .. tostring(t)
    end
    return retval
end

function table.tostring(t)
    if type(t) ~= "table" then
        return "UNKNOWN"
    else
        return __dump(t, 0, {})
    end
end





