local redis = require "resty.redis"

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

local KEY_RULE = "M_"
-- {"type":"cc", "value":{"cnt":100, "sec":60}, "code":"403", "block":true, "timeout":0},
-- get rules according to ip and uri, if do not match any specified rules,use default one
function _M.get_rules( ip, uri )
 
   local rules = [=[
        [
            
            {"type":"url","operate":"≈", "value":"test1","code":403}
        ]
    ]=]
    return rules
end


local function fetch_from_redis( ip, port, ip, uri )
    -- body
    local red = redis:new()

    red:set_timeout(1000)

    local ok, err = red:connect(ip, port)

    if not ok then
        ngx.log(ngx.ERR, "fail to connect to redis: ", err)
        return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
    end

    local res, err = red:hget(KEY_RULE, ip)

    res, err = red:hget(KEY_RULE, url)

    res, err = red:hget(KEY_RULE, ip .. url)

    res, err = red:hget(KEY_RULE, "default")
    
    if err then
        ngx.log(ngx.ERR, "fail to get rule: ", err)
        return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
    end

    return res
end

local function fetch_from_local_files( path_to_file )
    -- body
end

return _M
