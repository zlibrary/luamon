-------------------------------------------------------------------------------
--- 基于 'torch7.tester' 的测试组件
-------------------------------------------------------------------------------
local Tester = newclass("luamon.tester")

function Tester:init()
    self.errors   = {}
    self.tests    = {}
    self.warnings = {}
    self.disables = {}
    self._current = ""
end

function Tester:setEarlyAbort(earlyAbort)
    self.

