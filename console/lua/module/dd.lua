-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}

function _M.show()
    local name = ngx.var.arg_name

    if not name then
        return ngx.exit(400)
    end

    local shared = ngx.shared[name]

    local result = {}

    for _, key in pairs(shared:get_keys(0)) do 
        result[key] = shared:get(key)
    end

    ngx.say(json.encode(result))
end

return _M


