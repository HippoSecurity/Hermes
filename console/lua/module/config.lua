-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}

local KEY_CONFIG_ = "M_CONF_"

local function sys_cache_store(key, value)
    -- body
    local sys = ngx.shared["sys"]

    local succ, err, forc = sys:set(key, value)

    if not succ then
        ngx.log(ngx.WARN, "cached mid failed, err: ", err)
    end

    if forc then
        ngx.log(ngx.WARN, "forcible some key when sys_cache_store, key = ", key, "value = ", value)
    end

end

function _M.sys_fetch_mid()
    local sys = ngx.shared["sys"]

    local mid, _ = sys:get(KEY_CONFIG_ .. "MID")

    ngx.log(ngx.DEBUG, "get edge mid: ", mid)

    return mid
end

function _M.sys_fetch_addr()
    -- body
    local sys = ngx.shared["sys"]

    local addr, _ = sys:get(KEY_CONFIG_ .. "ADDR")

    ngx.log(ngx.DEBUG, "get upload addr: ", addr)

    return addr
end

-- init singleton configure
function _M.init()

    local path = ngx.config.prefix() .. "conf/config"

    local fd_read, err = io.open(path, 'r')
    local data = nil

    if fd_read then
        data = fd_read:read()
        fd_read:close()
    else
        return ngx.log(ngx.ERR, "open config file err: ", err)
    end

    local config = json.decode(data)

    if 32 == #config.mid then
        return sys_cache_store(KEY_CONFIG_ .. "MID", config.mid) 
    end

    -- maybe you can check invalid ip addr
    if not config.addr then
        return sys_cache_store(KEY_CONFIG_ .. "ADDR", config.addr)
    end

    config.mid = ngx.md5(ngx.time())

    data = json.encode(config)

    local fd_write, err = io.open(path, 'w')

    if fd_write then
        data = fd_write:write(data)
        fd_write:close()
    else
        return ngx.log(ngx.ERR, "write config file err: ", err)
    end

end

return _M
