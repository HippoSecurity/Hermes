local match = ngx.re.match

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 4)
_M._VERSION = '0.10'

local mt = { __index = _M }


-- url or ip maybe on rewrite phase

-- rule = [[{
--     "url":[
--         {"operate":"≈", "values":{},"code":"403"},
--         {"operate":"=", "values" :{}}
--     ],
--     "ua" : [
--         {"operate":"≈", "value":{}, "action" : "block", "code" : "403"}
--     ]    
-- }]]

-- maybe I can merge all rules into single one, so that match process can be faster
function _M.generate( rules )
    -- body
    -- do match job according to rules list which comes from params
    return rules
end

return _M