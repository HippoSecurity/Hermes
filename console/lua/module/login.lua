-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"
local cookie = require "resty.cookie"

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

function _M.test(  )
    -- body
    local ck = require "resty.cookie"

    local cookie, err = ck:new()

    -- local field, err = cookie:get("lang")

    -- if not field then
    --     ngx.log(ngx.ERR, err)
    --     return
    -- end

    local ok, err = cookie:set({
                    key = "Name", value = "Bob", path = "/",
                    domain = "example.com", secure = true, httponly = true,
                    expires = "Wed, 09 Jun 2021 10:18:14 GMT", max_age = 50,
                    extension = "a4334aebaec"
                })
    if not ok then
        ngx.log(ngx.ERR, err)
        return
    end
end

return _M


