local moduleName = 'mymodule'
local M = {}
_G[moduleName] = M

local function doPrint(v)
    print(v)
end

function M.MyPrint(v)
    doPrint(v)
end

return M