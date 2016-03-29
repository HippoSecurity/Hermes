-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-29 16:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}

local KEY_SUMMARY_REFRESHING_FLAG = "A_"

local KEY_URI_STATUS = "B_"
local KEY_URI_SIZE = "C_"
local KEY_URI_TIME = "D_"
local KEY_URI_COUNT = "E_"
local KEY_STATUS_INIT = "I_"
local KEY_START_TIME = "G_"
local KEY_TOTAL_COUNT = "F_"
local KEY_TOTAL_COUNT_SUCCESS = "H_"
local KEY_TRAFFIC_READ = "J_"
local KEY_TRAFFIC_WRITE = "K_"
local KEY_TIME_TOTAL = "L_"

-- maybe optimized, read from redis
function _M.init()

    local shared_status  = ngx.shared.status
    local shared_summary = ngx.shared.summary 

    local ok, err = shared_status:add( KEY_STATUS_INIT, true )

    if ok then
        shared_status:set( KEY_TOTAL_COUNT, 0 )
        shared_status:set( KEY_TOTAL_COUNT_SUCCESS, 0 )
        
        shared_status:set( KEY_TRAFFIC_READ, 0 )
        shared_status:set( KEY_TRAFFIC_WRITE, 0 )
        
        shared_status:set( KEY_TIME_TOTAL, 0 )
    end
end

--add global count info
function _M.log()
    local shared_status = ngx.shared.status

    shared_status:incr( KEY_TOTAL_COUNT, 1 )

    if tonumber(ngx.var.status) < 400 then
        shared_status:incr( KEY_TOTAL_COUNT_SUCCESS, 1 )
    end

    shared_status:incr( KEY_TRAFFIC_READ, ngx.var.request_length)
    shared_status:incr( KEY_TRAFFIC_WRITE, ngx.var.bytes_sent )
    shared_status:incr( KEY_TIME_TOTAL, ngx.var.request_time )
end

function _M.report()
    local shared_status = ngx.shared.status
    local var = ngx.var

    local report = {}
    report['request_all_count'] = shared_status:get( KEY_TOTAL_COUNT )
    report['request_success_count'] = shared_status:get( KEY_TOTAL_COUNT_SUCCESS )
    report['time'] = ngx.now()
    report['response_time_total'] = shared_status:get( KEY_TIME_TOTAL )
    
    report['traffic_read'] = shared_status:get( KEY_TRAFFIC_READ )
    report['traffic_write'] = shared_status:get( KEY_TRAFFIC_WRITE )
    return json.encode( report )

end

return _M
