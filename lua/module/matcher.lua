
local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 4)
_M._VERSION = '0.10'

local mt = { __index = _M }

function _M.new( ... )
    -- body
    -- may get an rules list from params
end

function _M.run( ... )
    -- body
    -- do match job according to rules list which comes from params
end

return _M