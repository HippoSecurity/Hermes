
local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 4)
_M._VERSION = '0.10'

local mt = { __index = _M }


-- url or ip maybe on rewrite phase

-- rule = [[
-- [
--     {"act":"url",operate":"≈", "values":"","code":"403"}
--     {"act":"ua", operate":"≈", "value":"", "code" : "403"}  
-- ]
--]]

-- get rules according to ip and uri, if do not match any specified rules,use default one
function _M.get_rules( ip, uri )
 
   local rules = [=[
        [
            {"type":"cc", "value":{"cnt":100, "sec":60}, "code":"403", "block":true, "timeout":0},
            {"type":"url","operate":"≈", "value":"test1","code":403}
        ]
    ]=]
    return rules
end

return _M
