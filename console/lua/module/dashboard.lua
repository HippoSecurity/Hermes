-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"
local cookie = require "resty.cookie"

local _M = {}

_M.mime_type = {}
_M.mime_type['.js'] = "application/x-javascript"
_M.mime_type['.css'] = "text/css"
_M.mime_type['.html'] = "text/html"

local function home_path()
    local current_script_path = debug.getinfo(1, "S").source:sub(2)
    local home_path = current_script_path:sub( 1, 0 - string.len("/lua/module/dashboard.lua") -1 ) 
    return home_path
end

_M.root_path = home_path()

function _M.init()
    ngx.header.content_type = "text/html"
    ngx.header.charset = "utf-8"
    for k,v in pairs( _M.mime_type ) do
        if string.sub(action, string.len(action) - string.len(k) + 1 ) == k then
            ngx.header.content_type = v
            break
        end
    end

    local path = _M.root_path .."dashboard" .. string.sub( ngx.var.uri, string.len( "/dashboard") + 1 )

    local f = io.open( path, 'r' )
    if f ~= nil then
        ngx.say( f:read("*all") )
        f:close()
        return 
    else        
        ngx.exit(404)
    end
end


function _M.run(self, action)
    -- body
    ngx.header.content_type = "text/html"
    ngx.header.charset = "utf-8"
    for k,v in pairs( _M.mime_type ) do
        if string.sub(action, string.len(action) - string.len(k) + 1 ) == k then
            ngx.header.content_type = v
            break
        end
    end

    local path = _M.root_path .."dashboard" .. string.sub( ngx.var.uri, string.len( "/dashboard") + 1 )

    local f = io.open( path, 'r' )
    if f ~= nil then
        ngx.say( f:read("*all") )
        f:close()
        return 
    else        
        ngx.exit(404)
    end

end

return _M


