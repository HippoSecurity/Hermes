-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"
-- local cookie = require "resty.cookie"

local _M = {}

function _M.login()
     local path = _M.root_path .."dashboard" .. string.sub( ngx.var.uri, string.len( "/dashboard") + 1 )

        local f = io.open( path, 'r' )
        if f ~= nil then
            ngx.say( f:read("*all") )
            f:close()
            ngx.exit(200)
        else        
            ngx.exit(404)
        end
end

return _M


