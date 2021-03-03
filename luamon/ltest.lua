-------------------------------------------------------------------------------
--- 测试框架（参考'torch7'设计实现）
-------------------------------------------------------------------------------

local NWIDTH = 90 -- 显示宽度

local function pluralize(num, str)
    local stem = num .. ' ' .. str
    if num <= 1 then
        return stem
    else
        return stem .. 's'
    end
end

local function bracket(str)
    return '[' .. str .. ']'
end

-- 着色处理
local colourable, colours = pcall(require, 'luamon.utils.colours')
local coloured
if not colourable then
    colours  = {}
    coloured = function(str)
        return str
    end
else
    coloured = function(str, colour)
        return colour .. str .. colours.none
    end
end

-----------------------------------------------------------
--- 断言结果处理

local function warning(obj, message)
    local name = obj.__current_test_name
    obj.__warning_counts[name] = obj.__warning_counts[name] + 1
    local errors = obj.__warning_errors[name]
    local errmsg = debug.traceback(message, 1)
    table.insert(errors, errmsg)
end

local function success(obj)
    local name = obj.__current_test_name
    obj.__success_counts[name] = obj.__success_counts[name] + 1
    return true
end

local function failure(obj, message, rethrow)
    if rethrow then
        error(debug.traceback(message, 3), 2)
    end
    local name = obj.__current_test_name
    obj.__failure_counts[name] = obj.__failure_counts[name] + 1
    local errors = obj.__failure_errors[name]
    local errmsg = debug.traceback(message, 3)
    table.insert(errors, errmsg)
    return false
end

---------------------------------------------------------------------
--- 辅助方法集
---------------------------------------------------------------------
local check = {}

function check.expect_eq(v1, v2, negate)
    local errmsg = nil
    if type(v1) ~= type(v2) then
        if not negate then
            errmsg = string.format('expect_eq(%s, %s) failed(difference types).', type(v1), type(v2))
        end
        return negate, errmsg
    else
        local ok = (v1 == v2)
        if negate then
            ok = not ok
        end
        if not ok then
            if negate then
                errmsg = string.format('expect_ne(%s, %s) failed.', tostring(v1), tostring(v2))
            else
                errmsg = string.format('expect_eq(%s, %s) failed.', tostring(v1), tostring(v2))
            end
        end
        return ok, errmsg
    end
end

function check.assert_eq(v1, v2, negate)
    local errmsg = nil
    if type(v1) ~= type(v2) then
        if not negate then
            errmsg = string.format('assert_eq(%s, %s) failed(difference types).', type(v1), type(v2))
        end
        return negate, errmsg
    else
        local ok = (v1 == v2)
        if negate then
            ok = not ok
        end
        if not ok then
            if negate then
                errmsg = string.format('assert_ne(%s, %s) failed.', tostring(v1), tostring(v2))
            else
                errmsg = string.format('assert_eq(%s, %s) failed.', tostring(v1), tostring(v2))
            end
        end
        return ok, errmsg
    end
end

---------------------------------------------------------------------
--- 测试方法集（提供测试器相关辅助）
---------------------------------------------------------------------

local block = {}

-----------------------------------------------------------
--- 数值比较逻辑

function block:expect_eq(v1, v2, message)
    local ok, errmsg = check.expect_eq(v1, v2)
    if ok then
        return success(self)
    else
        return failure(self, (message or '') .. errmsg)
    end
end

function block:assert_eq(v1, v2, message)

    local ok, errmsg = check.assert_eq(v1, v2)
    if ok then
        return success(self)
    else
        return failure(self, (message or '') .. errmsg, 'rethrow')
    end
end

function block:expect_ne(v1, v2, message)
    local ok, errmsg = check.expect_eq(v1, v2, 'negate')
    if ok then
        return success(self)
    else
        return failure(self, (message or '') .. errmsg)
    end
end

function block:assert_ne(v1, v2, message)
    local ok, errmsg = check.assert_eq(v1, v2, 'negate')
    if ok then
        return success(self)
    else
        return failure(self, (message or '') .. errmsg, 'rethrow')
    end
end

function block:expect_lt(v1, v2, message)
    if (v1 < v2) then
        return success(self)
    else
        local errmsg = string.format('%sexpect_lt(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg)
    end
end

function block:assert_lt(v1, v2, message)
    if (v1 < v2) then
        return success(self)
    else
        local errmsg = string.format('%sassert_lt(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_gt(v1, v2, message)
    if (v1 > v2) then
        return success(self)
    else
        local errmsg = string.format('%sexpect_gt(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg)
    end
end

function block:assert_gt(v1, v2, message)
    if (v1 > v2) then
        return success(self)
    else
        local errmsg = string.format('%sassert_gt(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_le(v1, v2, message)
    if (v1 <= v2) then
        return success(self)
    else
        local errmsg = string.format('%sexpect_le(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg)
    end
end

function block:assert_le(v1, v2, message)
    if (v1 <= v2) then
        return success(self)
    else
        local errmsg = string.format('%sasert_le(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_ge(v1, v2, message)
    if (v1 >= v2) then
        return success(self)
    else
        local errmsg = string.format('%sexpect_ge(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg)
    end
end

function block:assert_ge(v1, v2, message)
    if (v1 >= v2) then
        return success(self)
    else
        local errmsg = string.format('%sassert_ge(%s[%s], %s[%s]) failed.',
                                     message or '',
                                     tostring(v1), type(v1),
                                     tostring(v2), type(v2))
        return failure(self, errmsg, 'rethrow')
    end
end

-----------------------------------------------------------
--- 条件判断逻辑

function block:expect_true(condition, message)
    if type(condition) ~= 'boolean' then
        warning(self, 'warning : assert should only be used boolean conditions.')
    end
    if condition then
        return success(self)
    else
        local errmsg = string.format('%sexpect_true(%s[%s]) violation.',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg)
    end
end

function block:assert_true(condition, message)
    if type(condition) ~= 'boolean' then
        warning(self, 'warning : assert should only be used boolean conditions.')
    end
    if condition then
        return success(self)
    else
        local errmsg = string.format('%sassert_true(%s[%s]) violation.',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_false(condition, message)
    if type(condition) ~= 'boolean' then
        warning(self, 'warning : assert should only be used boolean conditions.')
    end
    if not condition then
        return success(self)
    else
        local errmsg = string.format('%sexpect_false(%s[%s]) violation.',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg)
    end
end

function block:assert_false(condition, message)
    if type(condition) ~= 'boolean' then
        warning(self, 'warning : assert should only be used boolean conditions.')
    end
    if not condition then
        return success(self)
    else
        local errmsg = string.format('%sassert_false(%s[%s]) violation.',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg, 'rethrow')
    end
end

-----------------------------------------------------------
--- 异常判断逻辑

function block:expect_error(fn, message)
    local ok, rvalue = pcall(fn)
    if not ok then
        return success(self)
    else
        local errmsg = string.format('%sexpect_error() violation : rvalue = %s',
                                     message or '',
                                     tostring(rvalue))
        return failure(self, errmsg)
    end
end

function block:assert_error(fn, message)
    local ok, rvalue = pcall(fn)
    if not ok then
        return success(self)
    else
        local errmsg = string.format('%sassert_error() violation : rvalue = %s',
                                     message or '',
                                     tostring(rvalue))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_not_error(fn, message)
    local ok, rvalue = pcall(fn)
    if ok then
        return success(self)
    else
        local errmsg = string.format('%sexpect_not_error() violation : err = %s',
                                     message or '',
                                     tostring(rvalue))
        return failure(self, errmsg)
    end
end

function block:assert_not_error(fn, message)
    local ok, rvalue = pcall(fn)
    if ok then
        return success(self)
    else
        local errmsg = string.format('%sassert_not_error() violation : err = %s',
                                     message or '',
                                     tostring(rvalue))
        return failure(self, errmsg, 'rethrow')
    end
end

-----------------------------------------------------------
--- 测试启动入口

function block:run()
    -- 构造测试环境
    local fixtures = getmetatable(self).fixtures or {}
    local tests    = getmetatable(self).tests    or {}
    local ncount   = 0
    local nerror   = 0
    rawset(self, '__success_counts', {})
    rawset(self, '__failure_counts', {})
    rawset(self, '__failure_errors', {})
    rawset(self, '__warning_counts', {})
    rawset(self, '__warning_errors', {})
    for _, v in ipairs(tests) do
        ncount = ncount + 1
        self.__success_counts[v.name] = 0
        self.__failure_counts[v.name] = 0
        self.__failure_errors[v.name] = {}
        self.__warning_counts[v.name] = 0
        self.__warning_errors[v.name] = {}
    end

    -- 进度显示参数
    local cstr    = string.format('%u', ncount)
    local cfmt    = string.format('[%%%uu/%u]', cstr:len(), cstr)
    local cfmtlen = cstr:len() * 2 + 3

    -- 开始测试操作
    io.write(coloured('Running ' .. pluralize(ncount, 'test'), colours.blue) .. '\n')      -- 显示测试用例总量
    io.write(coloured(string.rep('=', NWIDTH), colours.blue) .. '\n')
    local i = 1
    for _, v in ipairs(tests) do
        rawset(self, '__current_test_name', v.name)
        -- 显示用例状态
        local strinit = coloured(string.format(cfmt, i), colours.blue)
                        .. v.name
                        .. ' '
                        .. string.rep('.', NWIDTH - 8 - cfmtlen - v.name:len())
                        .. ' '
        io.write(strinit .. bracket(coloured('WAIT', colours.cyan)))
        io.flush()
        -- 执行测试用例
        if (fixtures.setup ~= nil) then
            fixtures.setup(v.name)
        end
        local ok, rvalue = xpcall(v.fn, debug.traceback)
        if not ok then
            self.__failure_counts[v.name] = self.__failure_counts[v.name] + 1
            local errors = self.__failure_errors[v.name]
            local errmsg = rvalue .. '\n'
            table.insert(errors, errmsg)
        end
        if (fixtures.teardown ~= nil) then
            fixtures.teardown(v.name)
        end
        -- 更新用例状态
        io.write('\r' .. strinit)
        if (self.__failure_counts[v.name] == 0) then
            io.write(bracket(coloured('PASS', colours.green)) .. '\n')
        else
            nerror = nerror + 1
            io.write(bracket(coloured('FAIL', colours.red)) .. '\n')
            -- 打印错误信息
            for j, text in ipairs(self.__failure_errors[v.name]) do
                io.write(text .. '\n')
                if (j < self.__failure_counts[v.name]) or (self.__warning_counts[v.name] > 0) then
                    io.write(string.rep('-' , NWIDTH) .. '\n')
                end
            end
        end
        -- 打印告警信息
        if (self.__warning_counts[v.name] ~= 0) then
            for j, text in ipairs(self.__warning_errors[v.name]) do
                io.write(text .. '\n')
                if (j < self.__warning_counts[v.name]) then
                    io.write(string.rep('-' , NWIDTH) .. '\n')
                end
            end
        end
        i = i + 1
        io.flush()
        collectgarbage()
    end

    -- 打印测试注脚
    local nasserts = 0
    local nfailure = 0
    local nwarning = 0
    for _, v in ipairs(tests) do
        nasserts = nasserts + self.__success_counts[v.name] + self.__failure_counts[v.name]
        nfailure = nfailure + self.__failure_counts[v.name]
        nwarning = nwarning + self.__warning_counts[v.name]
    end
    io.write(coloured(string.rep('=', NWIDTH), colours.blue) .. '\n')
    io.write(string.format('Completed %s in %s with %s and %s.\n',
                            pluralize(nasserts, 'assert'),
                            pluralize(ncount,   'test'  ),
                            coloured(pluralize(nfailure, 'failure'), nfailure == 0 and colours.green or colours.magenta),
                            coloured(pluralize(nwarning, 'warning'), nwarning == 0 and colours.green or colours.yellow)))
end

---------------------------------------------------------------------
--- 测试组件模型
---------------------------------------------------------------------

local module = {}

-- 创建测试器
function module.new()
    -- 构建测试元表
    local meta =
    {
        fixtures    = {},         -- 固件列表
        tests       = {},         -- 用例列表
    }
    meta.__index    = block
    meta.__newindex = function(_, k, fn)
        -- 类型检查
        if (type(fn) ~= 'function') then
            error('Only function supported.')
        end
        -- 方法注册
        local kname = string.lower(k)
        if (kname == 'setup') or (kname == 'teardown') then
            -- 测试固件
            if not meta.fixtures[kname] then
                meta.fixtures[kname] = fn
            else
                error(string.format("Only one %s function allowed.", k))
            end
        else
            -- 测试用例
            for _, v in ipairs(meta.tests) do
                if v.name == k then
                    error('Test with name[' .. k .. '] already exists.')
                end
            end
            table.insert(meta.tests, { name = k, fn = fn })
        end
    end
    -- 构建测试实例
    return setmetatable({}, meta)
end

-- 导出测试模型
return module
