-------------------------------------------------------------------------------
--- 仿照 'guava.cache' 实现的数据缓存模块
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local lhm       = require "luamon.container.linked-hashmap"
local iterator  = require "luamon.container.iterator"
local eraser    = require "luamon.cache.eraser"
local loader    = require "luamon.cache.loader"
local ticker    = require "luamon.cache.ticker"
local evbuilder = require "luamon.cache.evbuilder"

-------------------------------------------------------------------------------
--- 数值引用相关

local function __reference_new_object(cache, key, value)
    return 
    {
        cache    = assert(cache),
        key      = assert(key),
        value    = value,
        xtime    = cache.ticker:time(),
        event    = cache.evbuilder:build(),
        removing = nil,
        loading  = nil,
        abnormal = nil,
    }
end

local function __reference_is_removing(ref)
    if (ref.removing ~= nil) then
        return true
    else
        return false
    end
end

local function __reference_is_loading(ref)
    if (ref.loading ~= nil) then
        return true
    else
        return false
    end
end

local function __reference_is_expired(ref)
    if (ref.abnormal ~= nil) then
        return true
    else
        local tm = ref.cache.ticker:time()
        if (ref.cache.change_expired ~= nil) and (tm > (ref.xtime + ref.cache.change_expired)) then
            return true
        end
        if (ref.cache.access_expired ~= nil) and (tm > (ref.xtime + ref.cache.access_expired)) then
            return true
        else
            return false
        end
    end
end

local function __reference_is_abnormal(ref)
    if (ref.abnormal ~= nil) then
        return true
    else
        return false
    end
end

local function __reference_get_value(ref)
    if (ref.cache.access_expired ~= nil) then
        ref.xtime = ref.cache.ticker:time()
    end
    return ref.value
end

local function __reference_set_value(ref, v)
    ref.abnormal = nil
    ref.value    = v
    ref.xtime    = ref.cache.ticker:time()
end

local function __reference_wait(ref)
    assert(ref.removing ~= nil)
    assert(ref.loading  == nil)
    assert(ref.abnormal == nil)
    ref.event:wait()
    if (ref.abnormal ~= nil) then
        error(ref.abnormal)
    end
end

local function __reference_load(ref, cb)
    assert(ref.removing == nil)
    assert(ref.loading  == nil)
    assert(ref.abnormal == nil)
    local function load()
        if (type(cb) == "function" ) then
            return cb(ref.key)
        end
        if (ref.cache.loader == nil) then
            return nil
        else
            return ref.cache.loader:load(ref.key)
        end
    end    
    ref.loading  = true
    local ok, ret = xpcall(load, debug.traceback)
    if (not ok) then
        ref.abnormal = ret
        ref.loading  = nil
        ref.event:wakeup()
        error("__reference_load failed. " .. ret)
    else
        ref.loading  = nil
        ref.value    = ret
        ref.event:wakeup()
    end
end

local function __reference_evict(ref)
    assert(ref.removing == nil)
    assert(ref.loading  == nil)
    assert(ref.abnormal == nil)
    ref.removing = true
    pcall(function()
        if (ref.cache.eraser ~= nil) then
            ref.cache.eraser:exec(ref.key, ref.value)
        end
    end)
    ref.removing = nil
    ref.event:wakeup()
end

-------------------------------------------------------------------------------
--- 模块定义
local cache = newclass("luamon.cache.cache")

function cache:init(params)
    self.cacacity       = 0
    self.mcache         = lhm:new("access_order")
    self.ticker         = ticker:new()
    self.loader         = nil
    self.eraser         = nil
    self.evbuilder      = evbuilder:new()
    self.change_expired = nil
    self.access_expired = nil
    if (params ~= nil) then
        -- 设置缓存容量
        if (tonumber(params.capacity) ~= nil) then
            self.capacity = math.max(16, tonumber(params.capacity))
        end
        -- 设置事件生成器
        if (params.evbuilder ~= nil) then
            assert(evbuilder:made(params.evbuilder))
            self.evbuilder = params.evbuilder
        end
        -- 设置时钟对象
        if (params.ticker ~= nil) then
            assert(ticker:made(params.ticker))
            self.ticker = params.ticker
        end
        -- 设置数值加载器
        if (params.loader ~= nil) then
            assert(loader:made(params.loader))
            self.loader = params.loader
        end
        -- 设置数值移除器
        if (params.eraser ~= nil) then
            assert(eraser:made(params.eraser))
            self.eraser = params.eraser
        end
        -- 设置缓存访问后留存时长(秒)
        if (tonumber(params.access_expired) ~= nil) then
            self.access_expired = math.max(0, tonumber(params.access_expired))
        end
        -- 设置缓存更新后留存时长(秒)
        if (tonumber(params.change_expired) ~= nil) then
            self.change_expired = math.max(0, tonumber(params.change_expired))
        end
    end
end

function cache:capacity()
    return self.capacity
end

function cache:size()
    return self.mcache:size()
end

function cache:empty()
    return self.mcache:empty()
end

function cache:clear()
    local iter = self.mcache:xbegin()
    local xend = self.mcache:xend()
    while(true) do
        if (iter == xend) then
            break
        else
            local key = iter:get()[1]
            iter:advance(1)
            self:evict(key)
        end
    end
end

function cache:evict(key)
    local ref = self.mcache:get(key)
    if (ref == nil) then
        -- 目标不存在(操作目标不存在,放弃移除操作)
        return
    end
    if (__reference_is_loading(ref) == true) then
        -- 目标加载中(与当前操作无关,放弃移除操作)
        return
    end
    if (__reference_is_removing(ref) == true) then
        -- 目标移除中(需等待操作完成,确保操作顺序)
        __reference_wait(ref)
    else
        -- 执行移除操作
        __reference_evict(ref)
        self.mcache:erase(key)
    end
end

function cache:get(key, cb)
    local value = nil
    while(true) do
        local ref = self.mcache:get(key)
        if (ref == nil) then
            ref = __reference_new_object(self, key)
            self.mcache:insert(key, ref)
            __reference_load(ref, cb)
            if __reference_is_abnormal(ref) then
                ref = nil
                self.mcache:erase(key)
            end
        end
        if (__reference_is_loading(ref) or __reference_is_removing(ref)) then
            __reference_wait(ref)
        else
            if (__reference_is_expired(ref)  == true) then
                __reference_load(ref)
            end
            if (__reference_is_abnormal(ref) == true) then
                value = nil
                break
            else
                value = __reference_get_value(ref)
                break
            end
        end
    end
    if (self.capacity > 0) and (self.capacity < self.mcache:size()) then
        -- 移除溢出数据
        local entry = self.mcache:xbegin():get()
        local key   = entry[1]
        local ref   = entry[2]
        self:evict(key)
    end
    return value
end

function cache:put(key, value)
    while(true) do
        local ref = self.mcache:get(key)
        if (ref == nil) then
            ref = __reference_new_object(self, key, value)
            self.mcache:insert(key, ref)
        end
        if (__reference_is_loading(ref) or __reference_is_removing(ref)) then
            __reference_wait(ref)
        else
            __reference_set_value(ref, value)
            break
        end
    end
    if (self.capacity > 0) and (self.capacity < self.mcache:size()) then
        -- 移除溢出数据
        local entry = self.mcache:xebgin():get()
        local key   = entry[1]
        local ref   = entry[2]
        self:evict(key)
    end
end

function cache:__len()
    return self:size()
end

function cache:__pairs()
    local curr  = self.mcache:xbegin()
    local xend  = self.mcache:xend()
    local value = nil
    return function()
        if (curr == xend) then
            return nil
        else
            value = curr:get()
            curr:advance(1)
            return value[1], value[2]
        end
    end
end

return cache
