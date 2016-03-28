-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}

-- init singleton configure
function _M.init()

    local path = ngx.config.prefix() .. "conf/config"

    local f, err = io.open(path, 'r')
    local data = nil

    if f then
        data = f:read()
        f:close()
    else
        return ngx.log(ngx.ERR, "open config file err: ", err)
    end



end

return _M
