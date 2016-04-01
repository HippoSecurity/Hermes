-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local summary = require "lua.module.summary"
local status = require "lua.module.status"
local login  = require "lua.module.login"
local rpm    = require "lua.module.rpm"
local json = require "cjson"

local dd = require "lua.module.dd"

local _M = {}

_M.url_route = {}
_M.mime_type = {}
_M.mime_type['.js'] = "application/x-javascript"
_M.mime_type['.css'] = "text/css"
_M.mime_type['.html'] = "text/html"

function _M.run()
    -- body
    local action = string.lower(ngx.req.get_method().." "..ngx.var.uri)

    local handle = _M.url_route[ action ]
    if handle ~= nil and ngx.re.find(action, "(get|post) /api") then
        ngx.header.content_type = "application/json"
        ngx.header.charset = "utf-8"
        handle()
    elseif ngx.re.find(action,"(get|post) /dashboard") == 1 then
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
            ngx.exit(200)
        else        
            ngx.exit(404)
        end
    end

end

function _M.login()  
    -- local args = nil
    -- local err = nil
    -- local session = nil

    -- ngx.req.read_body()
    -- args, err = ngx.req.get_post_args()
    -- if not args then
    --     ngx.say("failed to get post args: ", err)
    --     return
    -- end

    -- for i,v in ipairs( VeryNginxConfig.configs['admin'] ) do
    --     if v['user'] == args['user'] and v['password'] == args["password"] and v['enable'] == true then
    --         session = ngx.md5(encrypt_seed.get_seed()..v['user'])
    --         ngx.header['Set-Cookie'] = {
    --             string.format("verynginx_session=%s; path=/verynginx", session ),
    --             string.format("verynginx_user=%s; path=/verynginx", v['user'] ),
    --         }
            
    --         return cjson.encode({["ret"]="success",["err"]=err})
    --     end
    -- end 
    
    -- return cjson.encode({["ret"]="failed",["err"]=err})
    return json.encode({["ret"]="success",["err"]=err})
end

local function home_path()
    local current_script_path = debug.getinfo(1, "S").source:sub(2)
    local home_path = current_script_path:sub( 1, 0 - string.len("/lua/module/router.lua") -1 ) 
    return home_path
end

_M.root_path = home_path()

_M.url_route["post /dashboard/login"] = login.login

_M.url_route["get /api/edges"] = status.edges

_M.url_route["get /api/report"] = status.report

_M.url_route["get /api/debug"] = dd.show

_M.url_route["get /api/test"] = login.test

-- set rules including add or upgrade
_M.url_route["post /api/add_rules"] = rpm.add

-- support to edge server
_M.url_route["post /api/upload_status"] = status.document

_M.url_route["get /api/fetch_rules"] = rpm.fetch

return _M
