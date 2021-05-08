-------------------------------------------------------------------------------
--- 序列容器，提供常量时间的查找/插入/删除操作（'插入/删除'仅限双端，其余位置需要线性时间）
-------------------------------------------------------------------------------
require "luamon"
local algorithm = require "luamon.container.algorithm"
local iterator  = require "luamon.container.iterator"

-------------------------------------------------------------------------------
local __deque_section_length = 8

-------------------------------------------------------------------------------
--- 迭代器（正向）
local __deque_iterator = newclass("__deque_iterator", require("luamon.container.traits.iterator"))

function __deque_iterator:init(obj, midx, cidx)
    self.super:init("random-access")
    self.__obj  = obj
    self.__midx = midx
    self.__cidx = cidx
end

function __deque_iterator:get()
    local mindex = self.__midx
    local cindex = self.__cidx
    return self.__obj.__sections[mindex][cindex]
end

function __deque_iterator:set(v)
    local mindex = self.__midx
    local cindex = self.__cidx
    self.__obj.__sections[mindex][cindex] = v
end

function __deque_iterator:advance(n)
    local nm = math.tointeger(n)
    if nm then
        local mindex = math.floor((nm + self.__cidx) / __deque_section_length) + self.__midx 
        local cindex = math.floor((nm + self.__cidx) % __deque_section_length)
        if (cindex == 0) then
            mindex = mindex - 1
            cindex = __deque_section_length
        end
        if (nm < 0) then
            local iter = self.__obj:xbegin()
            if (mindex < iter.__midx) or ((mindex == iter.__midx) and (cindex < iter.__cidx)) then
                error("out of range.")
            end
        end
        if (nm > 0) then
            local iter = self.__obj:xend()
            if (mindex > iter.__midx) or ((mindex == iter.__midx) and (cindex > iter.__cidx)) then
                error("out of range.")
            end
        end
        self.__midx = mindex
        self.__cidx = cindex
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __deque_iterator:prev()
    local tmp = __deque_iterator:new(self.__obj, self.__midx, self.__cidx)
    tmp:advance(-1)
    return tmp
end

function __deque_iterator:next()
    local tmp = __deque_iterator:new(self.__obj, self.__midx, self.__cidx)
    tmp:advance(1)
    return tmp
end

function __deque_iterator:distance(other)
    if (other.class == __deque_iterator) and (self.__obj == other.__obj) then
        local mdv = (other.__midx - self.__midx)
        local cdv = (other.__cidx - self.__cidx)
        return (mdv * __deque_section_length) + cdv
    else
        error(string.format("'%s[%s]' not match for 'iterator:distance()'.", tostring(other), type(other)))
    end
end

function __deque_iterator:__eq(other)
    if (other.class ~= __deque_iterator) or (self.__obj ~= other.__obj) then
        return false
    else
        return (self.__midx == other.__midx) and (self.__cidx == other.__cidx)
    end
end

function __deque_iterator:__add(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __deque_iterator:new(self.__obj, self.__midx, self.__cidx)
        iter:advance(nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function __deque_iterator:__sub(n)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local iter = __deque_iterator:new(self.__obj, self.__midx, self.__cidx)
        iter:advance(-nm)
        return iter
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

-------------------------------------------------------------------------------
--- 队列定义
local deque = newclass("luamon.container.deque", require("luamon.container.traits.container"))

local function __initialize_deque(deque, first, last)
    deque.__sections = {[1] = {}}
    deque.__head     = __deque_iterator:new(deque, 1, 1)
    deque.__tail     = __deque_iterator:new(deque, 1, 1)
    while(first ~= last) do
        local rvalue = first:get()
        first:advance(1)
        deque:push_back(rvalue)
    end
    return deque
end

function deque:xbegin()
    return (self.__head + 0)
end

function deque:xend()
    return (self.__tail + 0)
end

function deque:rbegin()
    return iterator:rbegin(self)
end

function deque:rend()
    return iterator:rend(self)
end

function deque:init(obj)
    self.super:init("sequential")
    obj = obj or {}
    if (type(obj) == "table") then
        __initialize_deque(self, iterator:xbegin(obj), iterator:xend(obj))
    else
        error(string.format("'%s[%s]' isn't valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function deque:capacity()
    return 0x7FFFFFFF
end

function deque:size()
    return self:xbegin():distance(self:xend())
end

function deque:empty()
    return self:xbegin() == self:xend()
end

function deque:resize(n, v)
    local nm = math.tointeger(n)
    if nm and (nm >= 0) then
        local size = self:size()
        if (nm >= size) then
            for i = (size + 1), nm do
                self:push_back(v)
            end
        else
            for i = (nm + 1), size do
                self:pop_back()
            end
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function deque:get(n)
    local nm = math.tointeger(n)
    if nm then
        return (self:xbegin() + nm - 1):get()
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function deque:set(n, v)
    local nm = math.tointeger(n)
    if nm then
        if (nm > 0) and (nm <= self:size()) then
            (self:xbegin() + nm - 1):set(v)
        else
            error("out of range.")
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'unsigned int'.", tostring(n), type(n)))
    end
end

function deque:front()
    return self:xbegin():get()
end

function deque:back()
    local tmp = self:xend()
    tmp = tmp - 1
    return tmp:get()
end

function deque:assign(obj)
    obj = obj or {}
    if (type(obj) == "table") then
        __initialize_deque(self, iterator:xbegin(obj), iterator:xend(obj))
    else
        error(string.format("'%s[%s]' isn't valid argument for type 'table'.", tostring(obj), type(obj)))
    end
end

function deque:push_front(v)
    local mindex = self.__head.__midx - 0
    local cindex = self.__head.__cidx - 1
    if (cindex == 0) then
        mindex = self.__head.__midx - 1
        cindex = __deque_section_length
        self.__sections[mindex] = {}
    end
    self.__head.__midx = mindex
    self.__head.__cidx = cindex
    self.__head:set(v)
end

function deque:pop_front()
    if (self:size() == 0) then
        return 
    end
    local mindex = self.__head.__midx + 0
    local cindex = self.__head.__cidx + 1
    if (cindex > __deque_section_length) then
        mindex = self.__head.__midx + 1
        cindex = 1
        self.__sections[mindex - 1] = {}
    end
    self.__head.__midx = mindex
    self.__head.__cidx = cindex
end

function deque:push_back(v)
    self.__tail:set(v)
    local mindex = self.__tail.__midx + 0
    local cindex = self.__tail.__cidx + 1
    if (cindex > __deque_section_length) then
        mindex = self.__tail.__midx + 1
        cindex = 1
        self.__sections[mindex] = {}
    end
    self.__tail.__midx = mindex
    self.__tail.__cidx = cindex
end

function deque:pop_back()
    if (self:size() == 0) then
        return 
    end
    local mindex = self.__tail.__midx - 0
    local cindex = self.__tail.__cidx - 1
    if (cindex == 0) then
        mindex = self.__tail.__midx - 1
        cindex = __deque_section_length
        self.__sections[mindex + 1] = nil
    end
    self.__tail.__midx = mindex
    self.__tail.__cidx = cindex
end

function deque:insert(pos, v)
    if (pos.class == __deque_iterator) and (pos.__obj == self) then
        if (math.abs(self.__head:distance(pos)) <= math.abs(self.__tail:distance(pos))) then
            self:push_front(v)
            local curr = (self.__head + 0)
            local next = (self.__head + 1)
            while(true) do
                if (next == pos) then
                    curr:set(v)
                    break
                else
                    curr:set(next:get())
                    curr:advance(1)
                    next:advance(1)
                end
            end
            return curr
        else
            self:push_back(v)
            local curr = (self.__tail - 0)
            local prev = (self.__tail - 1)
            while(true) do
                curr:advance(-1)
                if (curr == pos) then
                    curr:set(v)
                    break
                end
                prev:advance(-1)
                curr:set(prev:get())
            end
            return curr
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'iterator'.", tostring(pos), type(pos)))
    end
end

function deque:erase(pos)
    if (pos.class == __deque_iterator) and (pos.__obj == self) then
        if (pos == self.__tail) then
            return pos
        end
        if (math.abs(self.__head:distance(pos)) <= math.abs(self.__tail:distance(pos))) then
            local curr = (pos + 0)
            local prev = (pos + 0)
            while(true) do
                if (curr == self.__head) then
                    break
                else
                    prev:advance(-1)
                    curr:set(prev:get())
                    curr:advance(-1)
                end
            end
            self:pop_front()
            return (pos + 1)
        else
            local curr = (pos + 0)
            local next = (pos + 0)
            while(true) do
                next:advance(1)
                if (next == self.__tail) then
                    break
                end
                curr:set(next:get())
                curr:advance(1)
            end
            self:pop_back()
            return (pos + 0)
        end
    else
        error(string.format("'%s[%s]' is invalid argument for type 'iterator'.", tostring(pos), type(pos)))
    end
end

function deque:clear()
    self.__sections = {[1] = {}}
    self.__head = __deque_iterator:new(self, 1, 1)
    self.__tail = __deque_iterator:new(self, 1, 1)
end

function deque:__len()
    return self:size()
end

function deque:__pairs()
    local curr  = self:xbegin()
    local xend  = self:xend()
    local index = 0
    local value = nil
    return function()
        if (curr == xend) then
            return nil
        else
            value = curr:get()
            index = index + 1
            curr:advance(1)
            return index, value
        end
    end
end

return deque
