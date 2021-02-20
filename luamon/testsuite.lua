-------------------------------------------------------------------------------
--- 测试框架（参考'torch7'设计实现）
-------------------------------------------------------------------------------

local NWIDTH = 80     -- 显示宽度

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
if colourable then
    coloured = function(str, colour)
        return colour .. str .. colours.none
    end
else
    colours  = {}
    coloured = function(str, colour)
        return str
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
        local errmsg = string.format('%sLT failed : %s[%s] >= %s[%s]',
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
        local errmsg = string.format('%sLT failed : %s[%s] >= %s[%s]',
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
        local errmsg = string.format('%sGT failed : %s[%s] <= %s[%s]',
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
        local errmsg = string.format('%sGT failed : %s[%s] <= %s[%s]',
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
        local errmsg = string.format('%sLE failed : %s[%s] > %s[%s]',
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
        local errmsg = string.format('%sLE failed : %s[%s] > %s[%s]',
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
        local errmsg = string.format('%sGE failed : %s[%s] < %s[%s]',
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
        local errmsg = string.format('%sGE failed : %s[%s] < %s[%s]',
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
        warning(' :assert should only be used boolean conditions.')
    end
    if condition then
        return success(self)
    else
        local errmsg = string.format('%sviolation : condition = %s[%s]',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg)
    end
end

function block:assert_true(condition, message)
    if type(condition) ~= 'boolean' then
        warning(' :assert should only be used boolean conditions.')
    end
    if condition then
        return success(self)
    else
        local errmsg = string.format('%sviolation : condition = %s[%s]',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_false(condition, message)
    if type(condition) ~= 'boolean' then
        warning(' :assert should only be used boolean conditions.')
    end
    if not condition then
        return success(self)
    else
        local errmsg = string.format('%sviolation : condition = %s[%s]',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg)
    end
end

function block:assert_false(condition, message)
    if type(condition) ~= 'boolean' then
        warning(' :assert should only be used boolean conditions.')
    end
    if not condition then
        return success(self)
    else
        local errmsg = string.format('%sviolation : condition = %s[%s]',
                                     message or '',
                                     tostring(condition), type(condition))
        return failure(self, errmsg, 'rethrow')
    end
end

-----------------------------------------------------------
--- 异常判断逻辑

function block:expect_error(fn, message)
    local ok, errmsg = pcall(fn)
    if not ok then
        return success(self)
    else
        local errmsg = string.format('%sERROR violation : err = %s',
                                     message or '',
                                     tostring(errmsg))
        return failure(self, errmsg)
    end
end

function block:assert_error(fn, message)
    local ok, errmsg = pcall(fn)
    if not ok then
        return success(self)
    else
        local errmsg = string.format('%sERROR violation : err = %s',
                                     message or '',
                                     tostring(errmsg))
        return failure(self, errmsg, 'rethrow')
    end
end

function block:expect_not_error(fn, message)
    local ok, errmsg = pcall(fn)
    if ok then
        return success(self)
    else
        local errmsg = string.format('%sERROR violation : err = %s',
                                     message or '',
                                     tostring(errmsg))
        return failure(self, errmsg)
    end
end

function block:assert_not_error(fn, message)
    local ok, errmsg = pcall(fn)
    if ok then
        return success(self)
    else
        local errmsg = string.format('%sERROR violation : err = %s',
                                     message or '',
                                     tostring(errmsg))
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
    for name in pairs(tests) do
        ncount = ncount + 1
        self.__success_counts[name] = 0
        self.__failure_counts[name] = 0
        self.__failure_errors[name] = {}
        self.__warning_counts[name] = 0
        self.__warning_errors[name] = {}
    end

    -- 进度显示参数
    local cstr    = string.format('%u', ncount)
    local cfmt    = string.format('[%%%uu/%u]', cstr:len(), cstr)
    local cfmtlen = cstr:len() * 2 + 3

    -- 开始测试操作
    io.write('Running ' .. pluralize(ncount, 'test') .. '\n')                   -- 显示测试用例总量
    local i = 1
    for name, fn in pairs(tests) do
        rawset(self, '__current_test_name', name)
        -- 显示用例状态
        local strinit = coloured(string.format(cfmt, i), colours.cyan)
                        .. name
                        .. ' '
                        .. string.rep('.', NWIDTH - 6 - 2 - cfmtlen - name:len())
                        .. ' '
        io.write(strinit .. bracket(coloured('WAIT', colours.cyan)))
        io.flush()
        -- 执行测试用例
        if (fixtures.setup ~= nil) then
            fixtures.setup(name)
        end
        local ok, rvalue = pcall(fn)
        if not ok then
            self.__failure_counts[name] = self.__failure_counts[name] + 1
            local errors = self.__failure_errors[name]
            local errmsg = rvalue .. '\n'
            table.insert(errors, errmsg)
        end
        if (fixtures.teardown ~= nil) then
            fixtures.teardown(name)
        end
        -- 更新用例状态
        io.write('\r' .. strinit)
        if (self.__failure_counts[name] > 0) then
            nerror = nerror + 1
            io.write(bracket(coloured('FAIL', colours.magenta)))
        else
            io.write(bracket(coloured('PASS', colours.green)))
            if (self.__warning_counts[name] > 0) then
                io.write('\n' .. string.rep(' ', NWIDTH - 10))
                io.write(bracket(coloured('+warning', colours.yellow)))
            end
        end
        io.write('\n')
        io.flush()
        i = i + 1
        collectgarbage()
    end

    -- 打印测试注脚
    local nasserts = 0
    local nfailure = 0
    local nwarning = 0
    for name in pairs(tests) do
        nasserts = nasserts + self.__success_counts[name] + self.__failure_counts[name]
        nfailure = nfailure + self.__failure_counts[name]
        nwarning = nwarning + self.__warning_counts[name]
    end
    io.write(string.format('Completed %s in %s with %s and %s.\n',
                            pluralize(nasserts, 'assert'),
                            pluralize(ncount,   'test'  ),
                            coloured(pluralize(nfailure, 'failure'), nfailure == 0 and colours.green or colours.magenta),
                            coloured(pluralize(nwarning, 'warning'), nwarning == 0 and colours.green or colours.yellow)))
    -- 打印错误信息
    io.write('\n')
    io.write(coloured(string.format("%s[ERRORS]%s\n", string.rep('=', math.floor((NWIDTH - 8) / 2)), string.rep('=', math.floor((NWIDTH - 10) / 2))), colours.magenta))
    for name, errors in pairs(self.__failure_errors) do
        -- 构造标题格式
        local xnumber = #errors
        local xstr    = string.format('%u', xnumber)
        local xfmt    = string.format('[%%%uu/%u]', xstr:len(), xstr)
        local xfmtlen = xstr:len() * 2 + 3
        for i, text in ipairs(errors) do
            local headline = coloured(string.format(xfmt, i), colours.magenta)
                             .. name
                             .. ' '
                             .. string.rep('-', NWIDTH - 2 - xfmtlen - name:len())
                             .. ' '
            io.write(headline .. '\n')
            io.write(text .. '\n')
            io.flush()
        end
    end
    -- 打印警告信息
    for name, errors in pairs(self.__warning_errors) do
        -- 构造标题格式
        local xnumber = #errors
        local xstr    = string.format('%u', xnumber)
        local xfmt    = string.format('[%%uu/%u]', xstr:len(), xstr)
        local xfmtlen = xstr:len() * 2 + 3
        for i, text in ipairs(errors) do
            local headline = coloured(string.format(xfmt, i), colours.yellow)
                             .. name
                             .. ' '
                             .. string.rep('-', NWIDTH - 6 - 2 - xfmtlen - name:len())
                             .. ' '
            io.write(headline .. bracket(coloured('FAIL', colours.yellow)) .. '\n')
            io.write(text .. '\n')
            io.flush()
        end
    end
end

local meta = { tests = {} , __index = block }

function meta.__newindex(_, k, v)
    meta.tests[k] = v
end


local mytest = setmetatable({}, meta)

function mytest.testA()
    mytest:expect_eq(1, 2)
    mytest:expect_eq(1, 2)
    mytest:expect_eq(1, 2)
    mytest:expect_eq(1, 2)
end

mytest:run()



-- [xxxxxx]============================================================= 
-- [1/2]----------------------------------------------------------------
-- xxxx
-- [2/2]----------------------------------------------------------------
-- xxxx

-- [xxxxxx]============================================================= 
-- [1/2]----------------------------------------------------------------
-- xxxx
-- [2/2]----------------------------------------------------------------
-- xxxx



-- [ FAILURES ]========================================================

-- [WARNS]


-- local TestSuite = require "luamon.testsuite"
-- local mytest    = TestSuite:new()

-- function mytest.setup(name)
-- end

-- function mytest.teardown(name)
-- end

-- function mytest.testA()
--     mytest:EQ(...)
--     mytest:NE(...)
-- end

-- mytest:run()

-- -- 1. 重置'setup/teardown', 直接记录在 mytest 空间内应该是没有问题的。（'index'方法需要做一定的判断）
-- -- 2. 'run'方法不应该被覆盖
-- -- 3. 测试用例可以使用 __newindex 进行注册， 但是只能通过 run 方法访问。（'index'无法直接获得指定测试用例）

-- __index = 
-- {
--     1. 访问 'run' 方法。 (应该也可以放入 'fixtures' 中)
--     2. 访问相关断言操作。

--     -- 注意，方法是固定不变的（直接指向一个静态表对象应该是没有问题的）
-- }

-- __newindex = 
-- {
--     1. 注册 'setup/teardown' 方法， 写入 'fixtures' 中(因为只有 run 访问这两个方法， 所以可以强制转换为小写)

--     2. 注册测试用例， 写入 'tests' 中

--     -- 使用闭包指定数据存储位置？？
-- }



-- mytest = setmetatable({},
-- {
--     __index = function(_, k)

        


-- })



