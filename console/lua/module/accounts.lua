-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "lua.module.dkjson"
local cookie = require "resty.cookie"

local _M = {}

_M.accounts = {
     { user = "verynginx", password = "verynginx", auth = "admin"}
}

-- need to be opt
local function home_path()
    local current_script_path = debug.getinfo(1, "S").source:sub(2)
    local home_path = current_script_path:sub( 1, 0 - string.len("/lua/module/accounts.lua") -1 ) 
    return home_path
end

local function get_seed()
    -- body
    if _M.seed ~= nil then
        return _M.seed
    end
    
    --return saved seed
    local seed_path = home_path() .. "/encrypt_seed.json"
    
    local file = io.open( seed_path, "r")
    if file ~= nil then
        local data = file:read("*all");
        file:close();
        local tmp = json.decode( data )

        _M.seed = tmp['encrypt_seed']

        return _M.seed
    end


    --if no saved seed, generate a new seed and saved
    _M.seed = ngx.md5( ngx.now() )
    local new_seed_json = json.encode( { ["encrypt_seed"]= _M.seed }, {indent=true} )
    local file,err = io.open( seed_path, "w")
    
    if file ~= nil then
        file:write( new_seed_json )
        file:close()
        return _M.seed
    else
        ngx.log(ngx.STDERR, 'save encrypt_seed failed' )
        return ''
    end
        
end


function _M.check_session()
    -- get all cookies
    local user, session
    
    local cookie_obj, err = cookie:new()
    local fields = cookie_obj:get_all()
    if not fields then
        return false
    end
    
    user = fields['verynginx_user'] 
    session = fields['verynginx_session']
    
    if user == nil or session == nil then
        return false
    end
    
    for i,v in ipairs( _M.accounts ) do
        if v.user == user then
            if session == ngx.md5( get_seed()..v.user) then
                return true
            else
                return false
            end
        end
    end
    
    return false
end

function _M.login()
    local args = nil
    local err = nil

    ngx.req.read_body()
    args, err = ngx.req.get_post_args()
    if not args then
        ngx.say("failed to get post args: ", err)
        return
    end

    for i,v in ipairs( _M.accounts ) do
        if v.user == args['user'] and v.password == args["password"] then
            local data = {}
            data['ret'] = 'success'
            data['err'] = err
            data['verynginx_session'] = ngx.md5(get_seed()..v.user)
            data['verynginx_user'] = v.user
            -- data['auth'] = v.auth
            ngx.log(ngx.ERR, json.encode(data))
            
            return ngx.say(json.encode(data))
        end
    end 
    
    return json.encode({["ret"]="failed",["err"]=err})
end

function _M.test()
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

function _M.login1()  
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

return _M


