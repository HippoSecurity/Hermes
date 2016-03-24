-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-01-02 00:35
-- -- @Author  : Alexa (AlexaZhou@163.com)
-- -- @Link    : 
-- -- @Disc    : url router

-- local summary = require "summary"
local status = require "lua.module.status"
-- local cookie = require "cookie"
-- local VeryNginxConfig = require "VeryNginxConfig"
-- local encrypt_seed = require "encrypt_seed"
local json = require "cjson"

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
    if handle ~= nil then
        ngx.header.content_type = "application/json"
        ngx.header.charset = "utf-8"
        ngx.say(handle())
        -- if action == "post /login" then
        -- -- if action == "post /login" or _M.check_session() == true then
        --     ngx.say( handle() )
        --     ngx.exit(200)
        -- else
        --     local info = json.encode({["ret"]="failed",["err"]="need login"})
        --     ngx.say( info )
        --     ngx.exit(200)
        -- end
    elseif string.find(action,"get /dashboard") == 1 then
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
-- function _M.filter() 
--     local action = string.lower(ngx.req.get_method().." "..ngx.var.uri)
--     local handle = _M.url_route[ action ]
--     if handle ~= nil then
--         ngx.header.content_type = "application/json"
--         ngx.header.charset = "utf-8"
--         if action == "post /verynginx/login" or _M.check_session() == true then
--             ngx.say( handle() )
--             ngx.exit(200)
--         else
--             local info = cjson.encode({["ret"]="failed",["err"]="need login"})
--             ngx.say( info )
--             ngx.exit(200)
--         end
--     elseif string.find(action,"get /verynginx/dashboard") == 1 then
--         ngx.header.content_type = "text/html"
--         ngx.header.charset = "utf-8"
--         for k,v in pairs( _M.mime_type ) do
--             if string.sub(action, string.len(action) - string.len(k) + 1 ) == k then
--                 ngx.header.content_type = v
--                 break
--             end
--         end

--         local path = VeryNginxConfig.home_path() .."/dashboard" .. string.sub( ngx.var.uri, string.len( "/verynginx/dashboard") + 1 )
--         f = io.open( path, 'r' )
--         if f ~= nil then
--             ngx.say( f:read("*all") )
--             f:close()
--             ngx.exit(200)
--         else        
--             ngx.exit(404)
--         end
--     end
-- end

-- function _M.check_session()
--     -- get all cookies
--     local user, session
    
--     local cookie_obj, err = cookie:new()
--     local fields = cookie_obj:get_all()
--     if not fields then
--         return false
--     end
    
--     user = fields['verynginx_user'] 
--     session = fields['verynginx_session']
    
--     if user == nil or session == nil then
--         return false
--     end
    
--     for i,v in ipairs( VeryNginxConfig.configs['admin'] ) do
--         if v["user"] == user and v["enable"] == true then
--             if session == ngx.md5( encrypt_seed.get_seed()..v["user"]) then
--                 return true
--             else
--                 return false
--             end
--         end
--     end
    
--     return false
-- end

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

function _M.home_path()
    local current_script_path = debug.getinfo(1, "S").source:sub(2)
    local home_path = current_script_path:sub( 1, 0 - string.len("/lua/module/router.lua") -1 ) 
    return home_path
end

_M.root_path = _M.home_path()
_M.url_route["post /login"] = _M.login
-- _M.url_route["get /summary"] = summary.report
_M.url_route["get /status"] = status.report
-- _M.url_route["get /verynginx/config"] = VeryNginxConfig.report
-- _M.url_route["post /verynginx/config"] = VeryNginxConfig.set
-- _M.url_route["get /verynginx/loadconfig"] = VeryNginxConfig.load_from_file

return _M
